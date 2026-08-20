# Dockerfile cho grok-register-panel
# Build từ source: clone repo vào thư mục src/ trước khi build
#
# Cách sử dụng:
#   git clone https://github.com/lij768423-svg/grok-register-panel src/
#   docker compose build grok-register-panel

FROM python:3.12-slim

# Install system dependencies for Camoufox + Xvfb (headless browser)
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    xauth \
    wget \
    curl \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxss1 \
    libxtst6 \
    procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements và install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Download Camoufox browser engine
RUN python -m camoufox fetch

# Copy toàn bộ source code
COPY . .

# Data directories (sẽ được mount từ host)
RUN mkdir -p /app/accounts /app/log /app/cpa_auth /app/grok2api_auth

EXPOSE 8787

# Dùng Xvfb để chạy headless browser trong container
ENV GROK_USE_XVFB=1
ENV GROK_HEADLESS=1
ENV PYTHONUTF8=1

CMD ["python", "-u", "webui/monitor.py"]
