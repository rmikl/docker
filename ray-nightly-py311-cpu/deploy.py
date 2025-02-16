import ray
from ray import serve
import logging
import time 
from tiny_llm import TinyLLM

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def deploy_llm_service():
    try:
        # Initialize connection to cluster
        ray.init(address="auto")
        logger.info("Connected to Ray cluster")

        # Configure Serve for lap-dell node
        serve.start(
            http_options={
                "host": "0.0.0.0",
                "port": 8000,
                "location": "EveryNode"
            }
        )

        @serve.deployment(
            route_prefix="/generate",
            num_replicas=1,
            ray_actor_options={
                "num_cpus": 4,
                "resources": {"node:lap-dell": 0.1}  
                "memory": 10000 * 1024**3
            }
        )
        class LLMDeployment:
            def __init__(self):
                self.llm = TinyLLM()
            
            async def __call__(self, request):
                data = await request.json()
                return self.llm.predict(data["prompt"])

        # Deploy to lap-dell
        serve.run(LLMDeployment.bind())
        logger.info("HTTP endpoint available at /generate on lap-dell")

        # Keep alive
        while True:
            ray.get(LLMDeployment.get_handle().generate.remote("Heartbeat"))
            time.sleep(5)

    except Exception as e:
        logger.error(f"Deployment failed: {str(e)}")
        raise

if __name__ == "__main__":
    deploy_llm_service()