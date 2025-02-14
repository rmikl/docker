# Use Ray's official CPU image
FROM rayproject/ray:nightly-py311-cpu
# Install dependencies first (for layer caching)

# Install system dependencies
RUN sudo apt-get update && sudo apt-get install -y \
    git \
    wget \
    libopenblas-dev \
    && sudo rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install hf_transfer==0.1.4

# Copy application files
COPY tiny_llm.py .
COPY deploy.py .
COPY query_llm.py .
COPY download_model.py .

# Pre-download model with retries
RUN python download_model.py

# Health check for Kubernetes
HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8265 || exit 1

# Environment variables
ENV PYTHONUNBUFFERED=1
ENV RAY_DISABLE_IMPORT_WARNING=1
ENV HF_HUB_ENABLE_HF_TRANSFER=1

# Start deployment
CMD ["python", "deploy.py"]