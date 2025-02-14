import ray
import time
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def query_service():
    """Query the deployed LLM service"""
    try:
        ray.init(address="auto")
        logger.info("Connected to Ray cluster")
        
        actor = ray.get_actor("llm_actor")
        logger.info("Found LLM actor")
        
        while True:
            try:
                prompt = input("\nEnter prompt (or 'exit' to quit): ").strip()
                if prompt.lower() == 'exit':
                    break
                
                start_time = time.time()
                result = ray.get(actor.generate.remote(prompt))
                latency = time.time() - start_time
                
                logger.info(f"\nResponse ({latency:.2f}s):\n{result}\n")
                
            except KeyboardInterrupt:
                logger.info("\nExiting...")
                break
                
    except Exception as e:
        logger.error(f"Query failed: {str(e)}")
        raise

if __name__ == "__main__":
    query_service()