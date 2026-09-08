// Cordis plugin, loaded via `--patch` (see cordis-patches/hindsight-compaction-sink.cordis.yml
// and DSH_PATCH_FILES in statefulset.yaml -- same mechanism as the mcpproxy patch).
//
// On every compaction (automatic pressure-based, automatic context-overflow
// recovery, or manual /compact), writes the summary produced by the
// compaction backend directly to Hindsight (infra/hindsight, bank "dsh") via
// its HTTP API -- bypassing the mcpproxy-memory MCP tool path entirely, so
// this does not depend on a subagent being invoked or on the model deciding
// to call `retain`. Best-effort: a failed retain is logged and swallowed,
// never breaks the agent turn that triggered the compaction.
//
// `compaction/summary` is a log-only session event (no surfaceOp) appended
// by every one of the three compaction paths -- see
// packages/compaction/compaction-basic/src/region.ts (compactSurfaceRegion)
// in the deepseek-harness source tree. It carries the finished summary
// content blocks plus the shadowed-range metadata; see
// packages/compaction/compaction/src/types.ts for the full event shape.

export const name = 'hindsight-compaction-sink'

const HINDSIGHT_URL = process.env.HINDSIGHT_URL ?? 'http://hindsight-api.infra.svc.cluster.local:8888'
const BANK_ID = process.env.HINDSIGHT_BANK_ID ?? 'dsh'

/** Flatten a ContentBlock[] summary into plain text for retain. Only 'text'
 * blocks carry prose; anything else (future block types) is skipped rather
 * than guessed at. */
function summaryToText(blocks) {
  return blocks
    .filter((block) => block?.type === 'text' && typeof block.text === 'string')
    .map((block) => block.text)
    .join('\n\n')
    .trim()
}

export function apply(ctx) {
  ctx.on('session/event', (session, event) => {
    if (event.type !== 'compaction/summary') return

    const text = summaryToText(event.data.summary)
    if (text.length === 0) {
      ctx.logger.warn(
        'hindsight-compaction-sink: compaction %s produced no text content, skipping retain',
        event.data.compactionId,
      )
      return
    }

    const item = {
      content: text,
      context: 'compaction-summary',
      // Stable per-compaction id so a retry (e.g. after a hindsight-side
      // model crash, see the 2026-09-06 qwen3.8-27b crash in bank "dsh"'s
      // operation log) upserts instead of duplicating.
      document_id: `dsh-compaction-${event.data.compactionId}`,
    }

    // Fire-and-forget from the compaction's point of view -- this listener
    // must not delay or fail the turn that triggered compaction. Errors are
    // logged, not thrown.
    void (async () => {
      try {
        const response = await fetch(
          `${HINDSIGHT_URL}/v1/default/banks/${encodeURIComponent(BANK_ID)}/memories`,
          {
            method: 'POST',
            headers: { 'content-type': 'application/json' },
            body: JSON.stringify({ items: [item], async: true }),
          },
        )
        if (!response.ok) {
          const body = await response.text().catch(() => '<unreadable body>')
          ctx.logger.warn(
            'hindsight-compaction-sink: retain failed for compaction %s (session %s): HTTP %d %s',
            event.data.compactionId, session.id, response.status, body,
          )
          return
        }
        ctx.logger.info(
          'hindsight-compaction-sink: retained compaction %s summary (%d chars) from session %s',
          event.data.compactionId, text.length, session.id,
        )
      } catch (error) {
        ctx.logger.warn(
          'hindsight-compaction-sink: retain request errored for compaction %s (session %s): %o',
          event.data.compactionId, session.id, error,
        )
      }
    })()
  })
}
