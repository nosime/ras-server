# ras-server

Docker Compose stack gồm **Cloudflare Tunnel** + **grok2api** + **grok-register-panel**.

- **cloudflared** – Expose các service ra internet qua Cloudflare Tunnel (không cần mở port)
- **grok2api** – API gateway chuyển đổi Grok.com / console.x.ai thành OpenAI / Anthropic compatible API
- **grok-register-panel** – Web panel đăng ký hàng loạt tài khoản Grok bằng Camoufox + monitor realtime

---

## Cấu trúc thư mục

```
ras-server/
├── docker-compose.yml          # Entry point - include tất cả services
├── .env.example                # Template env toàn project
├── .env                        # (git-ignored) Env thực tế của bạn
├── .gitignore
│
├── services/
│   ├── cloudflared/
│   │   ├── docker-compose.yml
│   │   └── .env.example
│   ├── grok2api/
│   │   ├── docker-compose.yml
│   │   └── .env.example
│   └── grok-register-panel/
│       ├── docker-compose.yml
│       ├── .env.example
│       └── config.example.json  # Copy -> config.json (git-ignored)
│
├── data/                        # Persistent data (git-ignored nội dung)
│   ├── grok2api/
│   │   ├── data/               # SQLite DB (accounts.db)
│   │   └── logs/
│   └── grok-register-panel/
│       ├── accounts/           # Registered account files
│       ├── log/                # Panel logs, proxy pool, batch traffic
│       ├── cpa_auth/           # CPA auth JSON
│       └── grok2api_auth/      # grok2api auth JSON
│
└── shared/
    └── networks.yml            # Shared network config reference
```

---

## Bắt đầu nhanh

### 1. Clone & Setup env

```bash
git clone <your-repo-url>
cd ras-server

# Copy env template và điền thông tin
cp .env.example .env
```

### 2. Điền các biến bắt buộc trong `.env`

| Biến | Mô tả |
|------|-------|
| `CLOUDFLARE_TOKEN` | Token của Cloudflare Tunnel ([lấy tại đây](https://one.dash.cloudflare.com/)) |
| `MONITOR_TOKEN` | Access token cho grok-register-panel (≥32 ký tự random) |

Tạo `MONITOR_TOKEN` ngẫu nhiên:
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### 3. Cấu hình grok-register-panel

```bash
cp services/grok-register-panel/config.example.json services/grok-register-panel/config.json
# Chỉnh sửa config.json: điền email provider, proxy, v.v.
```

> **Bảo mật**: `config.json` đã được git-ignored. Không commit file này lên repo.

### 4. Khởi động

```bash
# Khởi động tất cả services
docker compose --profile all up -d

# Hoặc khởi động từng service riêng
docker compose --profile cloudflared up -d
docker compose --profile grok2api up -d
docker compose --profile grok-register-panel up -d

# Xem logs
docker compose logs -f

# Logs của service cụ thể
docker compose logs -f grok2api
docker compose logs -f grok-register-panel
```

---

## Truy cập

| Service | URL | Ghi chú |
|---------|-----|---------|
| grok2api Admin | `http://localhost:8000/admin/login` | Mật khẩu mặc định: `grok2api` |
| grok2api API | `http://localhost:8000/v1/chat/completions` | OpenAI-compatible |
| grok-register-panel | `http://localhost:8787` | Điền `MONITOR_TOKEN` để đăng nhập |

---

## Cập nhật

```bash
# Cập nhật tất cả images
docker compose --profile all pull
docker compose --profile all up -d

# Cập nhật chỉ grok2api (không ảnh hưởng service khác)
docker pull ghcr.io/jiujiu532/grok2api:latest
docker compose up -d --no-deps grok2api
```

---

## Cấu hình Cloudflare Tunnel

Sau khi lấy được `CLOUDFLARE_TOKEN` từ Cloudflare Dashboard, cấu hình route trong tunnel để trỏ đến:
- `grok2api`: `http://grok2api:8000`
- `grok-register-panel`: `http://grok-register-panel:8787`

> ⚠️ **Bảo mật**: Không nên expose `grok-register-panel` trực tiếp ra internet. Nếu cần truy cập từ xa, hãy dùng Cloudflare Access hoặc Tailscale.

---

## Liên kết

- [grok2api](https://github.com/jiujiu532/grok2api)
- [grok-register-panel](https://github.com/lij768423-svg/grok-register-panel)
- [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
