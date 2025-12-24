# VPS Deployment Guide

## Deployment Overview

This project uses GitHub Actions for automated VPS deployment with the following features:
- **Manual deployment** with workflow trigger
- **Automatic password management** for Pi-hole
- **Persistent configuration** using `.env` file
- **Clean deployment** with proper file handling
- **Service verification** after deployment

### Deployment

#### Manual Deployment
- **Trigger**: Manual workflow dispatch
- **Workflow**: `.github/workflows/deploy.yml`
- **Best for**: All environments
- **Process**:
  1. Push changes to your repository
  2. Manually trigger deployment from GitHub Actions
  3. Monitor deployment status in real-time

## Deployment Process

### Prerequisites
- VPS with Docker and Docker Compose installed
- Ports 53 (TCP/UDP), 80 (TCP), and 51820 (UDP) open
- Domain name pointing to your VPS (recommended)

### Manual Deployment
1. **Prepare your repository**
   - Fork this repository
   - Add your VPS SSH key to GitHub secrets as `VPS_SSH_KEY`
   - Add other required secrets (see below)

2. **Configure environment**
   - Copy `.env.example` to `.env`
   - Update values with your configuration
   - Push changes to your repository

3. **Trigger deployment**
   - Go to GitHub Actions
   - Select "Deploy to VPS"
   - Click "Run workflow"
   - Optionally enable cleanup of previous deployment
   - Monitor the deployment logs

### Required Environment Variables

Create a `.env` file on your VPS at `/docker/wgpihole/.env` with the following variables:

1. **`PIHOLE_WEBPASSWORD`**: Pi-hole admin password
2. **`WGEASY_PASSWORD_HASH`**: bcrypt hash for WG-Easy
3. **`WG_HOST`**: Your VPS IP address or domain
4. **`WG_PORT`**: WireGuard UDP port (default: 51820)
5. **`WG_ALLOWED_IPS`**: VPN routing (e.g., `0.0.0.0/0`)
6. **`TZ`**: Your timezone (e.g., `America/New_York`)

**Note**: The `adblock.list` file contains blocklists from [Hagezi DNS Blocklists](https://github.com/hagezi/dns-blocklists) which provide comprehensive ad-blocking coverage. You can modify this file to customize your blocklist sources.

### Required GitHub Secrets

Only one secret is required for GitHub Actions deployment:

1. **`VPS_SSH_KEY`**: Your SSH private key for VPS access

**Note**: The workflow expects the `.env` file to already exist on the VPS. It will verify its presence and use the values from there, not from GitHub secrets.

### Current Configuration

**Current setup**: Manual trigger only
- **Trigger**: Manual workflow dispatch from GitHub Actions
- **Pros**: Full control over when deployments happen
- **Cons**: Requires manual action for each deployment

### Deployment Strategy

**Approach: Stop and Restart (Recommended)**
- Stops existing containers before deployment
- Ensures clean state with new configuration
- Handles configuration changes properly
- Minimal downtime (~30 seconds)



### How It Works

1. **Validation**: Checks if `.env` exists on VPS
2. **Directory Setup**: Creates `/docker/wgpihole/` structure
3. **File Deployment**: Copies all configuration files
4. **Container Management**: Stops existing containers, starts new ones
5. **Health Check**: Verifies services are running
6. **Cleanup**: Removes old Docker images

### Manual Deployment (Alternative)

If you prefer manual deployment:

```bash
# SSH into your VPS
ssh your-user@your-vps-ip

# Create directory
mkdir -p /docker/wgpihole
cd /docker/wgpihole

# Copy files from your local machine
scp -r . your-user@your-vps-ip:/docker/wgpihole/

# Create .env file
cp .env.example .env
nano .env  # Edit with your values

# Deploy
docker-compose down
docker-compose up -d
```

### VPS Prerequisites

1. **Docker installed**
2. **Docker Compose installed**
3. **SSH access configured**
4. **Ports 53 (TCP/UDP), 80 (TCP), and 51820 (UDP) open**

### Troubleshooting

**Deployment fails:**
- Check GitHub secrets are correct
- Verify VPS SSH access
- Ensure Docker is running on VPS

**Services don't start:**
- Check logs: `docker-compose logs`
- Verify `.env` file contents
- Check port availability

**Missing .env file:**
- Workflow will fail with clear error message
- Create `/docker/wgpihole/.env` on VPS manually
- Or add secrets and redeploy

### Security Notes

- SSH keys are stored in GitHub secrets (encrypted)
- `.env` file is created with secrets, not committed
- Consider using GitHub's OIDC for better security
- Rotate SSH keys regularly
