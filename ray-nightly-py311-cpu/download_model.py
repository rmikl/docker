from transformers import AutoModelForCausalLM
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

MAX_RETRIES = 3
RETRY_DELAY = 30

def download_model():
    """Download model with retries and progress tracking"""
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            logger.info(f"Download attempt {attempt}/{MAX_RETRIES}")
            
            AutoModelForCausalLM.from_pretrained(
                "TinyLlama/TinyLlama-1.1B-Chat-v1.0",
                device_map="cpu",
                local_files_only=False,
                load_in_8bit=True,
                low_cpu_mem_usage=True
            )
            
            logger.info("Model downloaded successfully")
            return
            
        except Exception as e:
            logger.error(f"Attempt {attempt} failed: {str(e)}")
            if attempt < MAX_RETRIES:
                logger.info(f"Retrying in {RETRY_DELAY} seconds...")
                time.sleep(RETRY_DELAY)
    
    raise RuntimeError("Failed to download model after multiple attempts")

if __name__ == "__main__":
    download_model()