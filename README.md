# WG-PiHole Docker Setup

A secure, production-ready Docker Compose setup combining Pi-hole (DNS ad-blocker) with WG-Easy (WireGuard VPN manager) for private, ad-free internet access.

## Features

- **Pi-hole**: Network-wide ad blocking with DNS filtering
- **WG-Easy**: Simple WireGuard VPN management with web interface
- **Custom Blocklists**: Pre-configured with comprehensive ad-blocking
- **Secure by Default**: No hardcoded credentials, secure permissions
- **Automated Deployment**: One-click VPS deployment via GitHub Actions
- **Self-hosted**: Full control over your network and data
- **Persistent Storage**: All configurations survive container restarts

## Quick Start

### Prerequisites
- Docker and Docker Compose installed on your VPS
- Ports 53 (TCP/UDP), 80 (TCP), and 51820 (UDP) open in your firewall
- Domain name pointing to your VPS (recommended)

### Deployment Steps

**Option 1: GitHub Actions Deployment (Recommended)**
1. Fork this repository
2. Configure GitHub secrets (see DEPLOYMENT.md)
3. Trigger deployment from GitHub Actions
4. Access services at the provided URLs

**Option 2: Manual Deployment**
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd wgpihole
   ```
2. Create and configure .env file:
   ```bash
   cp .env.example .env
   nano .env  # Update with your settings
   ```
3. Start the services:
   ```bash
   docker compose up -d
   ```

### Access Services
- Pi-hole Admin: `http://<your-vps-ip>/admin`
- WG-Easy Web UI: `http://<your-vps-ip>:51821`

### First-Time Setup
   - The deployment will automatically set your Pi-hole admin password from the `.env` file
   - WireGuard client configurations can be downloaded from the WG-Easy web interface

## Configuration

### Environment Variables (.env)

Copy `.env.example` to `.env` and configure:

#### Pi-hole Configuration
- `PIHOLE_WEBPASSWORD`: Admin password for Pi-hole web interface
- `TZ`: Your timezone (e.g., `America/New_York`)

#### Blocklists Configuration
The project uses `adblock.list` for custom blocklists. You can edit this file to add or remove blocklist sources:

```bash
# Edit the blocklists file
nano adblock.list
```

The file contains URLs to various blocklist sources that will be automatically loaded by Pi-hole.

#### WG-Easy Configuration
- `WGEASY_PASSWORD_HASH`: bcrypt hash for VPN web interface
- `WG_HOST`: Your server's public IP or domain
- `WG_PORT`: WireGuard UDP port (default: 51820)
- `WG_ALLOWED_IPS`: Routes to push to clients

#### Network Options for `WG_ALLOWED_IPS`:
- **Full tunnel**: `0.0.0.0/0` (all traffic through VPN)
- **DNS only**: `172.20.0.2/32` (only Pi-hole DNS through VPN)
- **DNS + specific networks**: `172.20.0.2/32,192.168.1.0/24`
- **Split tunnel**: `10.0.0.0/8,172.16.0.0/12,192.168.0.0/16` (private networks only)

## Deployment

### VPS Deployment

This project supports automated deployment to your VPS via GitHub Actions.

#### Deployment Options

**Option 1: Manual Trigger Only (Current Setup)**
- **Trigger**: Manual workflow dispatch only
- **Use case**: Full control over when deployment happens
- **Workflow**: `deploy.yml` with `workflow_dispatch` only
- **Pros**: No accidental deployments, predictable timing
- **Cons**: Requires manual action for every deployment

**Option 2: Release-based (Production)**
- **Trigger**: Create GitHub release with tag
- **Use case**: Production deployments, version control
- **Workflow**: `release.yml`
- **Pros**: Controlled releases, rollback capability, version tracking

#### Required Secrets

Add these secrets to your GitHub repository (using exact names from .env.example):

1. **`PIHOLE_WEBPASSWORD`**: Pi-hole admin password
2. **`WGEASY_PASSWORD_HASH`**: bcrypt hash for WG-Easy
3. **`WG_HOST`**: Your VPS IP address or domain
4. **`WG_ALLOWED_IPS`**: VPN routing (e.g., `0.0.0.0/0`)
5. **`TZ`**: Your timezone (e.g., `America/New_York`)
6. **`VPS_SSH_KEY`**: Your SSH private key for VPS access
7. **`VPS_USER`**: SSH username (usually `root` or `ubuntu`)

#### Manual Deployment Process

1. Push code changes to GitHub
2. Go to repository → Actions → "Deploy to VPS"
3. Click "Run workflow" → Deploy

#### Release Deployment Process

1. Make changes to your code
2. Commit and push to main branch
3. Create release on GitHub:
   - Go to repository → Releases → "Create a new release"
   - Enter tag version (e.g., `v1.0.0`)
   - Write release notes
   - Click "Publish release"
4. Auto-deployment triggers automatically

### How Blocklists Work

**Blocklists are automatically initialized on first run based on blocklists.conf:**

1. Edit `blocklists.conf` to set `true`/`false` for each category
2. Run `docker-compose up -d`
3. On first run: Database is created with your selected blocklists
4. On subsequent runs: Existing database is used (preserves your settings)

**Available Categories in blocklists.conf:**
- **Core lists**: Ultimate, Pro, Pro+, Light, Multi
- **Content filtering**: Nosafe, Tracking, FakeNews, Gambling, Porn
- **Social media**: Social, TikTok, YouTube
- **Security**: Shortener, Risk, DNS-Rebind

**How it works:**
- Container runs `init-blocklists.sh` on startup
- Script only runs if `gravity.db` doesn't exist
- Enabled lists are added to database, disabled lists are added but inactive
- Pi-hole reads database and loads only enabled lists
- Database persists across container restarts

#### WG-Easy Configuration
- `WGEASY_PASSWORD_HASH`: bcrypt hash for VPN web interface
- `WG_HOST`: Your server's public IP or domain
- `WG_PORT`: WireGuard UDP port (default: 51820)
- `WG_ALLOWED_IPS`: Routes to push to clients

#### Network Options for `WG_ALLOWED_IPS`:
- **Full tunnel**: `0.0.0.0/0` (all traffic through VPN)
- **DNS only**: `172.20.0.2/32` (only Pi-hole DNS through VPN)
- **Split tunnel**: `10.0.0.0/8,172.16.0.0/12,192.168.0.0/16` (private networks only)
- **Custom**: Comma-separated list of networks

### Generate WG-Easy Password Hash

```bash
# Generate bcrypt hash (replace 'your_password' with your desired password)
htpasswd -nb -B admin your_password | cut -d: -f2
```

## Services

### Pi-hole
- **Web Interface**: http://your-server-ip/admin
- **DNS Ports**: 53/tcp, 53/udp (internal only)
- **Admin Password**: Set via `PIHOLE_WEBPASSWORD`

### WG-Easy
- **Web Interface**: http://your-server-ip:51821
- **VPN Port**: 51820/udp
- **Admin Password**: Set via `WGEASY_PASSWORD_HASH`

## Network Architecture

```
Internet → WG-Easy (172.20.0.3:51820) → Pi-hole (172.20.0.2:53) → Clean DNS
```

- `172.20.0.2`: Pi-hole DNS server
- `172.20.0.3`: WG-Easy VPN server
- Docker network: `wgpihole.net`

## Data Persistence

Configuration data is stored in local directories:
- `./etc/pihole/`: Pi-hole configuration and blocklists
- `./etc/dnsmasq.d/`: Custom DNS settings
- `./etc/wireguard/`: WireGuard client configurations

## Usage Examples

### DNS-Only VPN Setup
For ad-blocking without routing all traffic:
```bash
# In .env
WG_ALLOWED_IPS=172.20.0.2/32
```

### Full Tunnel Setup
Route all internet traffic through VPN:
```bash
# In .env
WG_ALLOWED_IPS=0.0.0.0/0
```

### Split Tunnel Setup
Route only private networks through VPN:
```bash
# In .env
WG_ALLOWED_IPS=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
```

## Management

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### View Logs
```bash
docker-compose logs -f
```

### Update Services
```bash
docker-compose pull
docker-compose up -d
```

## Security Notes

- All passwords are stored in environment variables (not in Docker Compose)
- `.env` file is excluded from version control via `.gitignore`
- Use strong, unique passwords for both services
- Consider using GitHub Secrets for CI/CD deployments

## Troubleshooting

### Common Issues

1. **VPN clients can't resolve DNS**
   - Ensure `WG_DEFAULT_DNS` points to `172.20.0.2`
   - Check Pi-hole is running: `docker-compose ps`

2. **Can't access web interfaces**
   - Verify ports are not blocked by firewall
   - Check containers are running: `docker-compose ps`

3. **Configuration not persisting**
   - Ensure volume mounts are correctly configured
   - Check permissions on local directories

### Reset Configuration
```bash
# Stop services
docker-compose down

# Remove configuration directories (WARNING: This deletes all settings!)
rm -rf ./etc/pihole ./etc/dnsmasq.d ./etc/wireguard

# Restart with fresh configuration
docker-compose up -d
```

## License

This project is provided as-is for educational and personal use.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request
