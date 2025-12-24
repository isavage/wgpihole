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

### Quick Start

**For detailed deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md)**

**Manual deployment (recommended):**
```bash
git clone <repository-url>
cd wgpihole
cp .env.example .env
nano .env  # Update with your settings
docker compose up -d
```

**GitHub Actions deployment:**
1. Fork this repository
2. Follow the setup instructions in [DEPLOYMENT.md](DEPLOYMENT.md)
3. Trigger deployment from GitHub Actions

### Access Services
- Pi-hole Admin: `http://<your-vps-ip>/admin`
- WG-Easy Web UI: `http://<your-vps-ip>:51821`

### First-Time Setup
   - The Pi-hole admin password is set from the `PIHOLE_WEBPASSWORD` variable in your `.env` file
   - WireGuard client configurations can be downloaded from the WG-Easy web interface
   - Allow a few minutes for services to fully initialize on first startup

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

The file contains URLs to various blocklist sources that will be automatically loaded by Pi-hole. We use blocklists from [Hagezi DNS Blocklists](https://github.com/hagezi/dns-blocklists) which provide comprehensive and well-maintained ad-blocking lists.

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

## Troubleshooting

### Common Issues

**Services won't start:**
- Check that ports 53, 80, and 51820 are open
- Verify Docker is running on the VPS
- Check container logs: `docker compose logs`

**Can't access Pi-hole admin:**
- Wait a few minutes for services to fully start
- The password is automatically set from your `.env` file
- Try accessing via `http://<your-vps-ip>/admin`

**VPN connection issues:**
- Ensure port 51820/UDP is open in your firewall
- Check that `WG_HOST` is set to your VPS public IP
- Download a new client config from WG-Easy web UI

### Logs and Debugging

```bash
# Check container status
docker compose ps

# View logs
docker compose logs pihole
docker compose logs wgeasy

# Restart services
docker compose restart
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
