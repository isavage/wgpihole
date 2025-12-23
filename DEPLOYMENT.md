# VPS Deployment Guide

## GitHub Actions Deployment

This project supports both development and production deployment strategies.

### Deployment Options

#### Option 1: Manual Trigger Only (Current Setup)
- **Trigger**: Manual workflow dispatch only
- **Use case**: Full control over when deployment happens
- **Workflow**: `deploy.yml` with `workflow_dispatch` only
- **Pros**: No accidental deployments, predictable timing
- **Cons**: Requires manual action for every deployment

#### Option 2: Push to Main (Development)
- **Trigger**: Push to `main` or `master` branch
- **Use case**: Rapid development, testing, staging
- **Workflow**: `deploy.yml` with push triggers
- **Pros**: Immediate deployment, fast iteration
- **Cons**: Less control over what gets deployed

#### Option 3: Release-based (Production)
- **Trigger**: Create GitHub release with tag
- **Use case**: Production deployments, version control
- **Workflow**: `release.yml`
- **Pros**: Controlled releases, rollback capability, version tracking
- **Cons**: Extra step to create release

### Release-based Deployment Process

1. **Make changes** to your code
2. **Commit and push** to main branch
3. **Create release** on GitHub:
   - Go to repository → Releases → "Create a new release"
   - Enter tag version (e.g., `v1.0.0`)
   - Write release notes
   - Click "Publish release"
4. **Auto-deployment** triggers automatically

### Required Secrets

Add these secrets to your GitHub repository (using exact names from .env.example):

1. **`PIHOLE_WEBPASSWORD`**: Pi-hole admin password
2. **`WGEASY_PASSWORD_HASH`**: bcrypt hash for WG-Easy
3. **`WG_HOST`**: Your VPS IP address or domain
4. **`WG_ALLOWED_IPS`**: VPN routing (e.g., `0.0.0.0/0`)
5. **`TZ`**: Your timezone (e.g., `America/New_York`)
6. **`VPS_SSH_KEY`**: Your SSH private key for VPS access
7. **`VPS_USER`**: SSH username (usually `root` or `ubuntu`)

### Deployment Control Strategies

#### Option 1: Branch Protection (Recommended)
- **Main branch**: Protected - Requires PR review
- **Development branch**: `develop` - Push triggers deployment
- **Production**: Merge to `main` → Create release → Deploy

#### Option 2: Manual Trigger Only
- **Disable push triggers** in workflow
- **Only manual deployment** via workflow_dispatch
- **Full control** - Deploy only when explicitly requested

#### Option 3: Tag-based Deployment
- **Current setup**: Push to main deploys, tags create releases
- **Alternative**: Only deploy on tags (set `branches: []`)
- **Clean separation**: Development pushes don't trigger deployment

#### Option 4: Environment-based
- **Development**: Push to `develop` → Deploy to staging
- **Production**: Push to `main` → Deploy to production
- **Requires**: Separate workflow files or environment variables

### Recommended Setup

1. **Protected main branch** - Require PR for production changes
2. **Development workflow** - `develop` branch deploys to staging
3. **Release workflow** - Tags deploy to production
4. **Manual override** - `workflow_dispatch` for emergency deployments

### Current Configuration

**Current setup**: Push to main + manual trigger
- **Pros**: Simple, flexible
- **Cons**: Every push deploys (may be too frequent)

### Deployment Strategy

**Approach: Stop and Restart (Recommended)**
- Stops existing containers before deployment
- Ensures clean state with new configuration
- Handles configuration changes properly
- Minimal downtime (~30 seconds)

**Alternative: Rolling Update**
- Starts new containers while old ones run
- Zero downtime but more complex
- Not implemented by default

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
4. **Ports 51820/udp and 51821/tcp open**

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
