# Qwen3.6-Plus Integration (Docker)

This project already supports Qwen via the `dashscope` provider.

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

