#!/bin/bash
# update.sh - Cập nhật ras-server + pull source repos mới nhất
# Chạy: bash update.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "  ras-server Update Script"
echo "========================================"

# ── 1. Pull ras-server config mới nhất ───────────────────────────────────────
echo "[1/4] Pull ras-server config mới nhất từ GitHub..."
git -C "$SCRIPT_DIR" pull
echo "  ✅ Xong"

# ── 2. Pull grok-register-panel source mới nhất ──────────────────────────────
PANEL_SRC="$SCRIPT_DIR/services/grok-register-panel/src"
if [ -d "$PANEL_SRC/.git" ]; then
    echo "[2/4] Pull grok-register-panel source mới nhất..."
    git -C "$PANEL_SRC" pull
    echo "  ✅ Xong"
else
    echo "[2/4] Chưa clone grok-register-panel, đang clone..."
    git clone https://github.com/lij768423-svg/grok-register-panel.git "$PANEL_SRC"
    echo "  ✅ Xong"
fi

# ── 3. Pull grok2api image mới nhất ──────────────────────────────────────────
echo "[3/4] Pull grok2api image mới nhất..."
docker pull ghcr.io/jiujiu532/grok2api:latest
docker pull cloudflare/cloudflared:latest
echo "  ✅ Xong"

# ── 4. Rebuild grok-register-panel và restart ─────────────────────────────────
echo "[4/4] Rebuild grok-register-panel và restart tất cả services..."
docker compose --profile all build grok-register-panel
docker compose --profile all up -d --pull never
echo "  ✅ Xong"

echo ""
echo "========================================"
echo "  Update hoàn tất!"
echo "========================================"
docker compose ps
