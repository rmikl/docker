FROM rayproject/ray:2.42.1-py311-cpu

# Install system dependencies
RUN sudo apt-get update && sudo apt-get install -y \
    libopenblas-dev \
    && sudo rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
#COPY *.py .

# Pre-download model
#RUN python download_model.py

#CMD ["python", "deploy.py"]