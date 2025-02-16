import ray
from ray import serve
import logging
import time
from tiny_llm import TinyLLM

logging.basicConfig(level=logging.DEBUG)  # Increased to DEBUG
logger = logging.getLogger(__name__)

def deploy_llm_service():
    try:
        # 1. Initialize Ray with explicit resource awareness
        ray.init(
            address="auto",
            runtime_env={"env_vars": {"RAY_RESOURCES": '{"lap-dell-node": 1}'}},
            logging_level="DEBUG"
        )
        logger.debug(f"Ray resources: {ray.cluster_resources()}")

        # 2. Explicit Serve initialization check
        logger.debug("Initializing Serve...")
        serve.start(
            http_options={
                "host": "0.0.0.0",
                "port": 8000,
                "location": "EveryNode"
            }
        )
        logger.debug(f"Serve status: {serve.status()}")

        # 3. Deployment with resource validation
        @serve.deployment(
            route_prefix="/generate",
            ray_actor_options={
                "num_cpus": 4,
                "resources": {"lap-dell-node": 0.1},
                "memory": 18 * 1024**3
            }
        )
        class LLMDeployment:
            def __init__(self):
                logger.debug("Initializing LLM...")
                self.llm = TinyLLM()
                logger.info("LLM ready on lap-dell-node")

            async def __call__(self, request):
                return self.llm.predict(await request.json())

        # 4. Deployment verification
        logger.debug("Binding deployment...")
        handle = serve.run(LLMDeployment.bind())
        logger.info("HTTP endpoint available at /generate")
        
        # 5. Active health checks
        while True:
            logger.debug("Health check...")
            ray.get(handle.generate.remote("Heartbeat"))
            time.sleep(5)

    except Exception as e:
        logger.critical(f"DEPLOYMENT FAILED: {str(e)}", exc_info=True)
        raise

if __name__ == "__main__":
    deploy_llm_service()