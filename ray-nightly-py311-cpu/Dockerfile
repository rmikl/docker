# Use Ray's official CPU image
FROM rayproject/ray:nightly-py311-cpu
# Install dependencies first (for layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy code
COPY tiny_llm.py .
COPY deploy.py .

# Pre-download model with retries and error handling
RUN python -c "\
import os; \
os.environ['HF_HUB_ENABLE_HF_TRANSFER'] = '1'; \
from transformers import AutoModelForCausalLM; \
AutoModelForCausalLM.from_pretrained( \
    'TinyLlama/TinyLlama-1.1B-Chat-v1.0', \
    device_map='cpu', \
    local_files_only=False \
)"

# Start your deployment
CMD ["python", "deploy.py"]