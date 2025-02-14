# Use Ray's official CPU image
FROM rayproject/ray:nightly-py311-cpu

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your code
COPY tiny_llm.py .
COPY deploy.py .

# Pre-download model weights (optional but recommended)
RUN python -c "from transformers import AutoModelForCausalLM; AutoModelForCausalLM.from_pretrained('TinyLlama/TinyLlama-1.1B-Chat-v1.0', device_map='cpu')"

# Start your deployment
CMD ["python", "deploy.py"]