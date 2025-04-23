# Use Node 18 on Debian 11 (Bullseye) slim for Playwright support
FROM node:18-bullseye-slim

# Allow overriding n8n version, default to latest
ARG N8N_VERSION="latest"

USER root

# Install OS dependencies for n8n build and browser automation
RUN apt-get update && apt-get install -y --no-install-recommends \
    # build tools and Python for n8n
    python3 build-essential pkg-config libcairo2-dev libglib2.0-dev \
    # n8n runtime dependencies
    git curl tzdata tini \
    # GUI dependencies for headless browsers
    xvfb chromium \
    # Fonts for rendering
    fonts-liberation fonts-noto-color-emoji fonts-unifont \
    xfonts-cyrillic xfonts-scalable fonts-ipafont-gothic fonts-wqy-zenhei fonts-tlwg-loma-otf fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists/*

# Install full ICU and n8n at specified version
RUN npm install -g full-icu n8n@${N8N_VERSION} && rm -rf /root/.npm
ENV NODE_ICU_DATA=/usr/lib/node_modules/full-icu

# Install automation libraries globally
RUN npm install -g puppeteer playwright selenium-webdriver chromedriver && rm -rf /root/.npm

# Configure Puppeteer to use installed Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Install Playwright dependencies and browsers
RUN npx playwright install-deps && npx playwright install

# Install n8n Puppeteer node
RUN cd /usr/local/lib/node_modules/n8n && npm install n8n-nodes-puppeteer && rm -rf /root/.npm

WORKDIR /data

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

EXPOSE 5678/tcp
