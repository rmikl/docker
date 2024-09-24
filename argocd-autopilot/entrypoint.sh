#!/bin/bash
set -e

if [ -z "$GIT_TOKEN" ]; then
    echo "Error: GIT_TOKEN environment variable is not set."
    exit 1
fi

if [ -z "$GIT_REPO" ]; then
    echo "Error: GIT_REPO environment variable is not set."
    exit 1
fi

argocd-autopilot repo bootstrap