#!/bin/bash
# setup.sh - Script khởi tạo dự án ras-server
# Chạy trên server Linux: bash setup.sh

set -e

echo "========================================"
echo "  ras-server Setup Script"
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── 0. ARM64 / Raspberry Pi: bật QEMU emulation cho amd64 containers ─────────
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    echo "[0/4] Phát hiện kiến trúc ARM64 (Raspberry Pi)..."
    echo "  Đang bật QEMU emulation cho amd64 (cần cho Camoufox)..."
    docker run --privileged --rm tonistiigi/binfmt --install amd64 2>/dev/null || true
    echo "  ✅ QEMU binfmt đã được cài đặt"
    echo "  ℹ️  grok-register-panel sẽ chạy qua QEMU emulation (chậm hơn ~2-3x so với native)"
fi

# ── 1. Tạo .env từ template ──────────────────────────────────────────────────
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "[1/4] Tạo .env từ .env.example..."
    cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
    
    # Tự động tạo MONITOR_TOKEN ngẫu nhiên
    MONITOR_TOKEN=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
    sed -i "s|your_strong_random_token_here_min_32_chars|$MONITOR_TOKEN|g" "$SCRIPT_DIR/.env"
    
    echo "  ✅ .env đã được tạo"
    echo "  ⚠️  Cần điền CLOUDFLARE_TOKEN vào .env trước khi chạy!"
else
    echo "[1/4] .env đã tồn tại, bỏ qua..."
fi

# ── 2. Clone grok-register-panel ─────────────────────────────────────────────
PANEL_SRC="$SCRIPT_DIR/services/grok-register-panel/src"
if [ ! -d "$PANEL_SRC/.git" ]; then
    echo "[2/4] Clone grok-register-panel..."
    git clone https://github.com/lij768423-svg/grok-register-panel.git "$PANEL_SRC"
    echo "  ✅ Đã clone xong"
else
    echo "[2/4] grok-register-panel/src đã tồn tại, pull updates..."
    git -C "$PANEL_SRC" pull
    echo "  ✅ Đã cập nhật"
fi

# ── 3. Tạo config.json cho panel ─────────────────────────────────────────────
PANEL_CONFIG="$SCRIPT_DIR/services/grok-register-panel/config.json"
if [ ! -f "$PANEL_CONFIG" ]; then
    echo "[3/4] Tạo config.json từ template..."
    cp "$SCRIPT_DIR/services/grok-register-panel/config.example.json" "$PANEL_CONFIG"
    chmod 600 "$PANEL_CONFIG"
    echo "  ✅ config.json đã được tạo"
    echo "  ⚠️  Cần điền email provider và proxy vào config.json!"
else
    echo "[3/4] config.json đã tồn tại, bỏ qua..."
fi

# ── 4. Tạo data directories ───────────────────────────────────────────────────
echo "[4/4] Tạo data directories..."
mkdir -p "$SCRIPT_DIR/data/grok2api/data"
mkdir -p "$SCRIPT_DIR/data/grok2api/logs"
mkdir -p "$SCRIPT_DIR/data/grok-register-panel/accounts"
mkdir -p "$SCRIPT_DIR/data/grok-register-panel/log"
mkdir -p "$SCRIPT_DIR/data/grok-register-panel/cpa_auth"
mkdir -p "$SCRIPT_DIR/data/grok-register-panel/grok2api_auth"
echo "  ✅ Data directories đã sẵn sàng"

echo ""
echo "========================================"
echo "  Setup hoàn tất!"
echo "========================================"
echo ""
echo "Bước tiếp theo:"
echo "  1. Điền CLOUDFLARE_TOKEN vào .env"
echo "  2. Điền email provider vào services/grok-register-panel/config.json"
echo "  3. Build & chạy:"
echo "     docker compose build grok-register-panel"
echo "     docker compose --profile all up -d"
echo ""
echo "Cloudflare Tunnel routes:"
echo "  grok2api:          http://grok2api:8000"
echo "  grok-register-panel: http://grok-register-panel:8787"
