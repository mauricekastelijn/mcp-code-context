FROM ollama/ollama:latest

# Install curl for healthchecks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Install the Cisco Umbrella Root CA certificate
# See https://docs.docker.com/engine/network/ca-certs/
COPY res/Cisco_Umbrella_Root_CA.cer /usr/local/share/ca-certificates/Cisco_Umbrella_Root_CA.crt
RUN update-ca-certificates

# Expose the default Ollama port
EXPOSE 11434

# Use the default entrypoint from the base image
