from transformers import AutoTokenizer, AutoModelForCausalLM

class TinyLLM:
    def __init__(self):
        # Use a tiny CPU-friendly model (~700MB)
        self.model = AutoModelForCausalLM.from_pretrained(
            "TinyLlama/TinyLlama-1.1B-Chat-v1.0", 
            device_map="cpu"
        )
        self.tokenizer = AutoTokenizer.from_pretrained(
            "TinyLlama/TinyLlama-1.1B-Chat-v1.0"
        )

    def predict(self, prompt: str) -> str:
        inputs = self.tokenizer(prompt, return_tensors="pt")
        outputs = self.model.generate(**inputs, max_new_tokens=50)
        return self.tokenizer.decode(outputs[0])