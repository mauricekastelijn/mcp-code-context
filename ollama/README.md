# Custom Ollama Container

This directory contains a custom Dockerfile for Ollama that includes corporate CA certificates.

## Setup

### 1. Add Your Certificate

Place your `Cisco_Umbrella_Root_CA.cer` file in the `res/` directory:

```
ollama/
  ├── Dockerfile
  ├── res/
  │   └── Cisco_Umbrella_Root_CA.cer  <- Place your certificate here
  └── README.md
```

### 2. Obtain the Certificate

**Option A: Export from Windows**
1. Press `Win + R`, type `certmgr.msc`
2. Navigate to: Trusted Root Certification Authorities → Certificates
3. Find "Cisco Umbrella Root CA"
4. Right-click → All Tasks → Export
5. Choose "Base-64 encoded X.509 (.CER)"
6. Save as `Cisco_Umbrella_Root_CA.cer`

**Option B: Export from Browser**
1. In Chrome/Edge, go to Settings → Privacy and Security → Security → Manage Certificates
2. Go to Trusted Root Certification Authorities
3. Find "Cisco Umbrella Root CA"
4. Export as Base-64 encoded X.509 (.CER)

### 3. Build and Run

After placing the certificate, the setup script will automatically build the custom container:

**Windows:**
```powershell
.\setup-windows.ps1
```

**Linux/Mac:**
```bash
./setup-linux.sh
```

Or manually:
```bash
docker-compose build ollama
docker-compose up -d
```

## What's Included

This custom Dockerfile adds:
- **curl** - Required for Docker health checks
- **CA certificate support** - For corporate proxies

The base `ollama/ollama:latest` image doesn't include curl, which causes health checks to fail.

## Troubleshooting

### Health Check Stuck on "Starting"

If your container is stuck in "starting" status:

```bash
# Rebuild to ensure curl is installed
docker-compose down
docker-compose build --no-cache ollama
docker-compose up -d

# Verify curl is available
docker exec ollama which curl

# Test health check manually
docker exec ollama curl -f http://localhost:11434/api/tags
```

### Certificate Not Found During Build

If you get an error about the certificate file not being found:

1. Verify the certificate file exists:
   ```
   ollama/res/Cisco_Umbrella_Root_CA.cer
   ```

2. Check the file is readable:
   ```bash
   # Windows
   Get-Content ollama\res\Cisco_Umbrella_Root_CA.cer

   # Linux
   cat ollama/res/Cisco_Umbrella_Root_CA.cer
   ```

3. Ensure it's in PEM format (starts with `-----BEGIN CERTIFICATE-----`)

### Different Certificate Name

If your organization uses a different certificate name:

1. Edit `ollama/Dockerfile`
2. Change the certificate filename in the COPY command
3. Rebuild: `docker-compose build ollama`

### Multiple Certificates

If you need to add multiple certificates:

```dockerfile
# In ollama/Dockerfile
COPY res/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates
```

Then place all certificates (with `.crt` extension) in the `res/` directory.

## Without Corporate Proxy

If you don't need the custom certificate (no corporate proxy):

1. Remove or comment out the COPY and RUN lines in `Dockerfile`
2. Or use the standard image by modifying `docker-compose.yml`:
   ```yaml
   ollama:
     image: ollama/ollama:latest  # Instead of building
     # build:
     #   context: ./ollama
   ```

## Verification

After building, verify the certificate is installed:

```bash
docker run --rm ollama/ollama:latest ls -la /usr/local/share/ca-certificates/
docker run --rm ollama/ollama:latest cat /etc/ssl/certs/ca-certificates.crt | grep Umbrella
```

## Reference

- [Docker CA Certificates Documentation](https://docs.docker.com/engine/network/ca-certs/)
- [Cisco Umbrella Certificate Info](https://docs.umbrella.com/)
