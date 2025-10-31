# Corporate Proxy Setup Guide

If you're working behind a corporate proxy or firewall (e.g., Cisco Umbrella, Zscaler, Blue Coat), you'll need to add your organization's CA certificate to the Ollama container.

## Quick Setup

### Step 1: Identify the Issue

You'll know you need this if you see errors like:
```
Error: pull model manifest: Get "https://registry.ollama.ai/v2/...": 
tls: failed to verify certificate: x509: certificate signed by unknown authority
```

### Step 2: Get Your CA Certificate

Choose the method that works for you:

#### Option A: Export from Windows Certificate Store

1. Press `Win + R`, type `certmgr.msc`, press Enter
2. Navigate to: **Trusted Root Certification Authorities** → **Certificates**
3. Find your organization's root CA (common names):
   - "Cisco Umbrella Root CA"
   - "Zscaler Root CA"
   - "Blue Coat"
   - "[Your Company Name] Root CA"
4. Right-click the certificate → **All Tasks** → **Export**
5. Choose **"Base-64 encoded X.509 (.CER)"**
6. Save as `Cisco_Umbrella_Root_CA.cer` (or your cert name)

#### Option B: Export from Browser

**Chrome/Edge:**
1. Settings → Privacy and Security → Security → **Manage Certificates**
2. Go to **Trusted Root Certification Authorities** tab
3. Find your organization's certificate
4. Select it and click **Export**
5. Choose **Base-64 encoded X.509 (.CER)**

**Firefox:**
1. Settings → Privacy & Security → **View Certificates**
2. Go to **Authorities** tab
3. Find your organization's certificate
4. Select and click **Export**
5. Save as .cer file

#### Option C: Contact IT Department

Ask your IT department for:
- The root CA certificate
- In PEM or CER format
- Base-64 encoded

### Step 3: Place the Certificate

1. **Navigate to the project directory:**
   ```bash
   cd mcp-code-context
   ```

2. **Place your certificate:**
   ```
   ollama/
     └── res/
         └── Cisco_Umbrella_Root_CA.cer  ← Place here
   ```

   The exact path should be:
   ```
   mcp-code-context/ollama/res/Cisco_Umbrella_Root_CA.cer
   ```

3. **Verify the file:**
   
   **Windows (PowerShell):**
   ```powershell
   Get-Content ollama\res\Cisco_Umbrella_Root_CA.cer -Head 5
   ```

   **Linux/Mac:**
   ```bash
   head -5 ollama/res/Cisco_Umbrella_Root_CA.cer
   ```

   You should see:
   ```
   -----BEGIN CERTIFICATE-----
   MIIFdzCCA1+gAwIBAgIQE6...
   ```

### Step 4: Run Setup

Now run the normal setup script, which will automatically build the container with your certificate:

**Windows:**
```powershell
.\setup-windows.ps1
```

**Linux/Mac:**
```bash
chmod +x setup-linux.sh
./setup-linux.sh
```

The setup will:
- Build a custom Ollama container
- Install your CA certificate
- Pull the embedding model
- Verify everything works

### Step 5: Verify

After setup completes, verify the certificate was installed:

```bash
docker exec ollama ls -la /usr/local/share/ca-certificates/
```

You should see your certificate listed.

## Different Certificate Name?

If your organization uses a different certificate name:

1. **Note the exact filename** (e.g., `CompanyName_Root_CA.cer`)

2. **Edit the Dockerfile:**
   ```bash
   # Edit ollama/Dockerfile
   ```

3. **Update the COPY line:**
   ```dockerfile
   # Change from:
   COPY res/Cisco_Umbrella_Root_CA.cer /usr/local/share/ca-certificates/Cisco_Umbrella_Root_CA.crt

   # To (using your filename):
   COPY res/YourCompany_Root_CA.cer /usr/local/share/ca-certificates/YourCompany_Root_CA.crt
   ```

4. **Rebuild:**
   ```bash
   docker-compose build ollama
   docker-compose up -d
   ```

## Multiple Certificates?

If you need to add multiple CA certificates:

1. **Place all certificates in `ollama/res/`:**
   ```
   ollama/res/
     ├── Root_CA_1.cer
     ├── Root_CA_2.cer
     └── Intermediate_CA.cer
   ```

2. **Edit `ollama/Dockerfile`:**
   ```dockerfile
   # Replace the COPY line with:
   COPY res/*.cer /usr/local/share/ca-certificates/
   RUN update-ca-certificates
   ```

3. **Rebuild:**
   ```bash
   docker-compose build ollama
   docker-compose up -d
   ```

## Troubleshooting

### Certificate File Not Found During Build

**Error:**
```
COPY failed: file not found in build context
```

**Solution:**
1. Verify the file exists:
   ```bash
   ls -la ollama/res/
   ```
2. Check the filename exactly matches what's in the Dockerfile
3. Ensure you're running the command from the project root directory

### Certificate Still Not Working

**1. Verify certificate format:**
```bash
# Should show "-----BEGIN CERTIFICATE-----"
cat ollama/res/Cisco_Umbrella_Root_CA.cer
```

If it shows binary data, convert to PEM:
```bash
# Windows
certutil -encode original.cer converted.cer

# Linux
openssl x509 -inform DER -in original.cer -out converted.cer
```

**2. Check if certificate is actually installed:**
```bash
docker exec ollama cat /etc/ssl/certs/ca-certificates.crt | grep -i "umbrella"
```

**3. Rebuild completely:**
```bash
docker-compose down
docker-compose build --no-cache ollama
docker-compose up -d
```

### Wrong Certificate?

If you're not sure which certificate to use:

**1. Test certificate on host machine:**
```bash
# Windows (PowerShell)
certutil -verify -urlfetch Cisco_Umbrella_Root_CA.cer

# Linux
openssl verify -CAfile Cisco_Umbrella_Root_CA.cer Cisco_Umbrella_Root_CA.cer
```

**2. Check what certificates are being used:**
```bash
# Visit a test site through the proxy
curl -v https://registry.ollama.ai 2>&1 | grep -i certificate
```

**3. Ask your IT department** for the correct certificate chain

## Don't Have Corporate Proxy?

If you're not behind a corporate proxy and don't need custom certificates:

### Option 1: Use Default Image (Recommended)

Edit `docker-compose.yml`:
```yaml
ollama:
  container_name: ollama
  image: ollama/ollama:latest  # Use this line
  # build:                      # Comment out these
  #   context: ./ollama         # Comment out these
  #   dockerfile: Dockerfile    # Comment out these
```

### Option 2: Simplify Dockerfile

Edit `ollama/Dockerfile` to remove certificate lines:
```dockerfile
FROM ollama/ollama:latest

# COPY and RUN lines removed

EXPOSE 11434
```

Then rebuild:
```bash
docker-compose build ollama
docker-compose up -d
```

## Security Notes

### ⚠️ Never Commit Certificates to Git

The `.gitignore` file is already configured to exclude certificates:
```gitignore
ollama/res/*.cer
ollama/res/*.crt
ollama/res/*.pem
```

**Always verify before committing:**
```bash
git status
```

If you see certificate files listed, do NOT commit them!

### 🔒 Certificate Storage

- Keep certificates secure
- Don't share in Slack/Email
- Use secure file transfer if needed
- Delete old certificates when no longer needed

## Common Corporate Proxies

| Proxy Solution | Certificate Name | Notes |
|----------------|------------------|-------|
| Cisco Umbrella | Cisco Umbrella Root CA | Most common |
| Zscaler | Zscaler Root CA | May have multiple |
| Blue Coat | Blue Coat Systems | Older proxy solution |
| Symantec | Symantec Root CA | Used by some orgs |
| Forcepoint | Forcepoint Root CA | Enterprise proxy |

## Testing

After setup, test the container can pull models:

```bash
# Should succeed without certificate errors
docker exec ollama ollama pull nomic-embed-text
```

If successful, you'll see:
```
pulling manifest
pulling 970aa74c0a90... 100%
success
```

## Additional Help

- See [ollama/README.md](./ollama/README.md) for more details
- See [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md) for general issues
- Check Docker logs: `docker-compose logs ollama`

## Quick Reference

```bash
# Place certificate
cp /path/to/cert.cer ollama/res/Cisco_Umbrella_Root_CA.cer

# Verify it's there
ls -la ollama/res/

# Build and start
docker-compose build ollama
docker-compose up -d

# Check it worked
docker exec ollama ls -la /usr/local/share/ca-certificates/

# Test model download
docker exec ollama ollama pull nomic-embed-text
```

---

**Questions?** Open an issue or consult your IT department for certificate-related questions.
