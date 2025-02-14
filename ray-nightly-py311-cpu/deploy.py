import ray
import logging
from tiny_llm import TinyLLM

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def deploy_llm_actor():
    """Deploys the LLM actor to the cluster"""
    try:
        # Initialize connection to cluster
        ray.init(address="auto")
        logger.info("Connected to Ray cluster")

        # Define the actor class
        @ray.remote(
            num_cpus=2, 
            resources={"node:lap-msi": 0.1},
            max_restarts=3,
            max_task_retries=2
        )
        class LLMActor:
            def __init__(self):
                self.llm = TinyLLM()
                self.logger = logging.getLogger(__name__)
            
            def generate(self, text: str) -> str:
                try:
                    return self.llm.predict(text)
                except Exception as e:
                    self.logger.error(f"Generation failed: {str(e)}")
                    raise

        # Deploy with a named actor
        actor = LLMActor.options(name="llm_actor").remote()
        
        # Verify deployment
        try:
            test_response = ray.get(actor.generate.remote("Ray is"))
            logger.info(f"Deployment test successful. Sample response: {test_response[:60]}...")
        except Exception as e:
            logger.error(f"Deployment verification failed: {str(e)}")
            raise

        return actor

    except ConnectionError:
        logger.error("Failed to connect to Ray cluster. Is it running?")
        raise

if __name__ == "__main__":
    actor = deploy_llm_actor()
    logger.info("LLM actor deployed successfully. Keep this running to maintain service.")
    ray.get(actor.generate.remote("Heartbeat"))  # Block to keep alive