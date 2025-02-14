import ray
from tiny_llm import TinyLLM

# Connect to your Ray cluster
ray.init(address="auto")  # Auto-connect to existing cluster

@ray.remote(num_cpus=2)  # Reserve 2 CPUs for this actor
class LLMActor:
    def __init__(self):
        self.llm = TinyLLM()
    
    def generate(self, text: str) -> str:
        return self.llm.predict(text)

# Deploy to any available worker node
actor = LLMActor.remote()

# Test it
result = ray.get(actor.generate.remote("What is Ray?"))
print(f"Response: {result}")