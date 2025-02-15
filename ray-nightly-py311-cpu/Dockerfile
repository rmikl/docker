FROM rayproject/ray:nightly-py311-cpu

# Install system dependencies
RUN sudo apt-get update && sudo apt-get install -y \
    libopenblas-dev \
    libopenmpi-dev \
    && sudo rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install bitsandbytes --prefer-binary

# Copy application files
COPY tiny_llm.py .
COPY deploy.py .
COPY query_llm.py .
COPY download_model.py .

# Pre-download model with nightly-compatible config
RUN python download_model.py

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8265 || exit 1

CMD ["python", "deploy.py"]