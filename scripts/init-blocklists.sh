#!/bin/bash

# Init script that runs only when gravity.db doesn't exist
# This runs inside the Pi-hole container on startup

CONFIG_FILE="/blocklists.conf"
PIHOLE_DB="/etc/pihole/gravity.db"

# Function to add adlist to database
add_adlist() {
    local url=$1
    local comment=$2
    local enabled=$3
    
    if [ "$enabled" = "true" ]; then
        echo "   ✅ Adding: $comment"
        sqlite3 "$PIHOLE_DB" "INSERT OR IGNORE INTO adlist (address, comment, enabled) VALUES ('$url', '$comment', 1);" 2>/dev/null
    else
        echo "   ❌ Skipping: $comment"
        sqlite3 "$PIHOLE_DB" "INSERT OR IGNORE INTO adlist (address, comment, enabled) VALUES ('$url', '$comment', 0);" 2>/dev/null
    fi
}

# Only run if gravity.db doesn't exist
if [ -f "$PIHOLE_DB" ]; then
    echo "📋 Gravity database already exists, skipping initialization"
    exit 0
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: $CONFIG_FILE not found!"
    exit 1
fi

echo "🔧 Initializing blocklists database (first run)..."

# Source the configuration
source "$CONFIG_FILE"

# Create adlists table structure
sqlite3 "$PIHOLE_DB" "
CREATE TABLE IF NOT EXISTS adlist (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    address TEXT NOT NULL UNIQUE,
    comment TEXT,
    enabled INTEGER NOT NULL DEFAULT 1,
    date_added INTEGER,
    date_modified INTEGER,
    date_updated INTEGER
);
" 2>/dev/null

# Add each blocklist based on configuration
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/ultimate.txt" "Hagezi Ultimate" "$HAGEZI_ULTIMATE"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/pro.txt" "Hagezi Pro" "$HAGEZI_PRO"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/pro-plus.txt" "Hagezi Pro Plus" "$HAGEZI_PRO_PLUS"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/light.txt" "Hagezi Light" "$HAGEZI_LIGHT"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/multi.txt" "Hagezi Multi" "$HAGEZI_MULTI"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/nosafe.txt" "Hagezi Nosafe" "$HAGEZI_NOSAFE"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/tracking.txt" "Hagezi Tracking" "$HAGEZI_TRACKING"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/fakenews.txt" "Hagezi FakeNews" "$HAGEZI_FAKENEWS"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/gambling.txt" "Hagezi Gambling" "$HAGEZI_GAMBLING"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/porn.txt" "Hagezi Porn" "$HAGEZI_PORN"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/social.txt" "Hagezi Social" "$HAGEZI_SOCIAL"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/tiktok.txt" "Hagezi TikTok" "$HAGEZI_TIKTOK"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/youtube.txt" "Hagezi YouTube" "$HAGEZI_YOUTUBE"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/shortener.txt" "Hagezi Shortener" "$HAGEZI_SHORTENER"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/risk.txt" "Hagezi Risk" "$HAGEZI_RISK"
add_adlist "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/dns-rebind.txt" "Hagezi DNS Rebind" "$HAGEZI_DNS_REBIND"

echo "✅ Blocklist initialization completed!"
echo "📊 Enabled lists: $(sqlite3 "$PIHOLE_DB" "SELECT COUNT(*) FROM adlist WHERE enabled = 1;" 2>/dev/null || echo "0")"
echo "📊 Total lists: $(sqlite3 "$PIHOLE_DB" "SELECT COUNT(*) FROM adlist;" 2>/dev/null || echo "0")"
