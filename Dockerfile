ARG UV_BASE_IMAGE=ghcr.1ms.run/astral-sh/uv:python3.12-bookworm-slim
ARG NODE_BASE_IMAGE=docker.1ms.run/library/node:20-bookworm-slim
ARG NPM_REGISTRY=https://registry.npmmirror.com
ARG DEBIAN_MIRROR=mirrors.aliyun.com
ARG PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/
ARG PIP_EXTRA_INDEX_URL=https://pypi.org/simple

FROM ${NODE_BASE_IMAGE} AS bridge-builder

ARG NPM_REGISTRY

WORKDIR /app/bridge
COPY bridge/package.json bridge/tsconfig.json ./
COPY bridge/src ./src
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates git && \
    rm -rf /var/lib/apt/lists/*
RUN npm config set registry ${NPM_REGISTRY} && \
    npm install && \
    npm run build

FROM ${UV_BASE_IMAGE}

ARG DEBIAN_MIRROR
ARG PIP_INDEX_URL
ARG PIP_EXTRA_INDEX_URL

# Use China mainland mirrors for Debian and PyPI
RUN if [ -f /etc/apt/sources.list ]; then \
      sed -i "s|deb.debian.org|${DEBIAN_MIRROR}|g; s|security.debian.org|${DEBIAN_MIRROR}|g" /etc/apt/sources.list; \
    fi && \
    if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
      sed -i "s|http://deb.debian.org|https://${DEBIAN_MIRROR}|g; s|http://security.debian.org|https://${DEBIAN_MIRROR}|g; s|https://deb.debian.org|https://${DEBIAN_MIRROR}|g; s|https://security.debian.org|https://${DEBIAN_MIRROR}|g" /etc/apt/sources.list.d/debian.sources; \
    fi && \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates git && \
    rm -rf /var/lib/apt/lists/*

# Provide Node.js 20 + npm in runtime container (for WhatsApp bridge commands)
COPY --from=bridge-builder /usr/local/bin/node /usr/local/bin/node
COPY --from=bridge-builder /usr/local/bin/npm /usr/local/bin/npm
COPY --from=bridge-builder /usr/local/bin/npx /usr/local/bin/npx
COPY --from=bridge-builder /usr/local/lib/node_modules /usr/local/lib/node_modules

ENV PIP_INDEX_URL=${PIP_INDEX_URL}
ENV PIP_EXTRA_INDEX_URL=${PIP_EXTRA_INDEX_URL}

WORKDIR /app

# Install Python dependencies first (cached layer)
COPY pyproject.toml README.md LICENSE ./
RUN mkdir -p nanobot bridge && touch nanobot/__init__.py && \
    uv pip install --system --no-cache . && \
    rm -rf nanobot bridge

# Copy the full source and install
COPY nanobot/ nanobot/
COPY bridge/ bridge/
RUN uv pip install --system --no-cache .

# Build the WhatsApp bridge
WORKDIR /app/bridge
COPY --from=bridge-builder /app/bridge/dist ./dist
WORKDIR /app

# Create config directory
RUN mkdir -p /root/.nanobot

# Gateway default port
EXPOSE 18790

ENTRYPOINT ["nanobot"]
CMD ["status"]
