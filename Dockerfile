# Base image: lightweight Python with Linux utilities
FROM python:3.11-slim

# Install essentials
RUN apt update && apt install -y git curl vim jq && \
    pip install --no-cache-dir requests rich httpx openai anthropic google-generativeai

# Install Node.js + npm
RUN apt update && apt install -y curl \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt install -y nodejs \
  && npm install -g yarn pnpm

# Create workspace inside container
WORKDIR /workspace

# Optional: install your favorite CLI utilities
RUN pip install fastfetch termcolor

# Entry point
CMD ["/bin/bash"]
