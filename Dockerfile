# Use Debian-based Node image for broader compatibility
FROM node:16-slim

# Provide a default version if not passed explicitly
ARG N8N_VERSION="latest"

USER root

# Install OS dependencies for n8n, Chromium, Puppeteer, Playwright, Selenium
RUN apt-get update && apt-get install -y \
    # basic tools
    git curl wget ca-certificates fonts-liberation tzdata \
    # build tools for n8n
    python3 build-essential \
    # Chromium dependencies
    chromium \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxcomposite1 libxdamage1 libxrandr2 libxss1 libgbm1 libasound2 libpangocairo-1.0-0 \
    # Selenium (Java) prerequisites
    openjdk-11-jre-headless unzip \
 && rm -rf /var/lib/apt/lists/*

# Install n8n at specified version
RUN npm install -g full-icu n8n@${N8N_VERSION}
ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu

# Install Puppeteer, Playwright, and Selenium WebDriver
RUN npm install -g puppeteer playwright selenium-webdriver

# Install Playwright browsers
RUN npx playwright install --with-deps

# Download ChromeDriver for Selenium
RUN CHROME_DRIVER_VERSION=$(curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE) && \
    wget -q "https://chromedriver.storage.googleapis.com/${CHROME_DRIVER_VERSION}/chromedriver_linux64.zip" -O /tmp/chromedriver.zip && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/chromedriver && \
    rm /tmp/chromedriver.zip

# Set Puppeteer executable path
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Install n8n-nodes-puppeteer
RUN cd /usr/local/lib/node_modules/n8n && npm install n8n-nodes-puppeteer

# Create n8n user workspace
WORKDIR /data

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

EXPOSE 5678
