import ray
from ray import serve  # <-- Add Serve import
import logging
from tiny_llm import TinyLLM

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def deploy_llm_service():  # Renamed for clarity
    try:
        ray.init(address="auto")
        logger.info("Connected to Ray cluster")

        # Start Serve with HTTP endpoint
        serve.start(
            http_options={
                "host": "0.0.0.0",
                "port": 8000,
                "location": "EveryNode"
            }
        )

        @serve.deployment(route_prefix="/generate")
        @ray.remote(num_cpus=2, resources={"node:lap-msi": 0.1})
        class LLMDeployment:
            def __init__(self):
                self.llm = TinyLLM()
            
            async def __call__(self, request):
                data = await request.json()
                return self.llm.predict(data["prompt"])

        # Deploy both actor and HTTP endpoint
        serve.run(LLMDeployment.bind())
        logger.info("HTTP endpoint available at /generate")

        # Keep the service running
        while True:
            ray.get(serve.get_deployment("LLMDeployment").get_handle().generate.remote("Heartbeat"))
            time.sleep(5)

    except Exception as e:
        logger.error(f"Deployment failed: {str(e)}")
        raise

if __name__ == "__main__":
    deploy_llm_service()