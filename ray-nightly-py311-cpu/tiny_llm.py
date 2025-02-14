from transformers import AutoTokenizer, AutoModelForCausalLM
import logging
import torch

class TinyLLM:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.device = "cpu"
        self.model = None
        self.tokenizer = None
        self._load_model()

    def _load_model(self):
        """Load model with error handling and optimizations"""
        try:
            self.logger.info("Loading TinyLlama model...")
            
            self.model = AutoModelForCausalLM.from_pretrained(
                "TinyLlama/TinyLlama-1.1B-Chat-v1.0",
                device_map=self.device,
                load_in_8bit=True,
                torch_dtype=torch.float16,
                low_cpu_mem_usage=True
            )
            
            self.tokenizer = AutoTokenizer.from_pretrained(
                "TinyLlama/TinyLlama-1.1B-Chat-v1.0"
            )
            
            self.logger.info("Model loaded successfully")
            
        except Exception as e:
            self.logger.error(f"Model loading failed: {str(e)}")
            raise

    def predict(self, prompt: str) -> str:
        """Generate response with input validation"""
        if not prompt or not isinstance(prompt, str):
            raise ValueError("Prompt must be a non-empty string")
            
        try:
            inputs = self.tokenizer(
                prompt,
                return_tensors="pt",
                max_length=512,
                truncation=True
            ).to(self.device)
            
            outputs = self.model.generate(
                **inputs,
                max_new_tokens=100,
                do_sample=True,
                temperature=0.7,
                top_k=50,
                top_p=0.95,
                repetition_penalty=1.2
            )
            
            return self.tokenizer.decode(
                outputs[0], 
                skip_special_tokens=True
            )
            
        except Exception as e:
            self.logger.error(f"Prediction failed: {str(e)}")
            raise