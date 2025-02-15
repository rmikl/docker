from transformers import AutoModelForCausalLM
import logging
import torch

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def download_model():
    try:
        logger.info("Loading model with CPU optimization")
        
        AutoModelForCausalLM.from_pretrained(
            "TinyLlama/TinyLlama-1.1B-Chat-v1.0",
            device_map="cpu",
            torch_dtype=torch.float16,
            low_cpu_mem_usage=True
        )
        
        logger.info("Model loaded successfully")
        
    except Exception as e:
        logger.error(f"Failed to load model: {str(e)}")
        raise

if __name__ == "__main__":
    download_model()