# Qwen3.6-Plus Integration (Docker)

This project already supports Qwen via the `dashscope` provider.

## China mainland mirror defaults in this repo

This deployment now defaults to:

- Docker base images: `ghcr.1ms.run/...` and `docker.1ms.run/...`
- Debian apt mirror: `mirrors.aliyun.com`
- Python package mirror: `https://mirrors.aliyun.com/pypi/simple/`
- npm registry mirror: `https://registry.npmmirror.com`

You can override all of them through compose build args.

## 1) Verify official API call first

Use Alibaba Cloud DashScope OpenAI-compatible endpoint:

```bash
curl -X POST https://dashscope.aliyuncs.com/compatible-mode/v1/responses \
  -H "Authorization: Bearer $DASHSCOPE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3.6-plus",
    "input": "Hello from nanobot deployment test."
  }'
```

If you use Singapore or US region, replace host with:
- Singapore: `https://dashscope-intl.aliyuncs.com/compatible-mode/v1`
- US: `https://dashscope-us.aliyuncs.com/compatible-mode/v1`

## 2) Prepare nanobot runtime config

```bash
mkdir -p ./nanobot-data
cp ./deploy/config.qwen3.6-plus.example.json ./nanobot-data/config.json
```

Edit `./nanobot-data/config.json`:
- Set `providers.dashscope.apiKey` to your real DashScope API key
- Keep `agents.defaults.model` as `qwen3.6-plus`

Important:
- Do not commit real keys into git
- Keep `tools.restrictToWorkspace=true` for production

## 3) Start with docker compose

```bash
docker compose -f deploy/docker-compose.qwen.yml up -d --build
```

Check status:

```bash
docker compose -f deploy/docker-compose.qwen.yml logs -f
```

Stop:

```bash
docker compose -f deploy/docker-compose.qwen.yml down
```

## 4) Optional: override mirror settings

Create `deploy/.env`:

```bash
UV_BASE_IMAGE=ghcr.1ms.run/astral-sh/uv:python3.12-bookworm-slim
NODE_BASE_IMAGE=docker.1ms.run/library/node:20-bookworm-slim
DEBIAN_MIRROR=mirrors.aliyun.com
PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
PIP_EXTRA_INDEX_URL=https://pypi.org/simple
NPM_REGISTRY=https://registry.npmmirror.com
```

Then run compose as usual.
