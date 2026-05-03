# Groq API Proxy — Cloudflare Worker

This Worker sits between the Flutter app and the Groq API, keeping the API key server-side and out of the APK.

## How it works

```
Flutter app  →  POST https://<your-worker>.workers.dev  →  Groq API
                (no Authorization header)                  (key injected by Worker)
```

## Deploy steps

### 1. Install Wrangler CLI

```bash
npm install -g wrangler
wrangler login
```

### 2. Create the Worker

```bash
wrangler init groq-proxy
# When prompted, choose "Hello World" worker
# Replace the generated worker code with groq-proxy.js
```

Or deploy directly without a project directory:

```bash
wrangler deploy groq-proxy.js --name groq-proxy --compatibility-date 2024-01-01
```

### 3. Set the API key as a secret

```bash
wrangler secret put GROQ_API_KEY
# Paste your Groq API key when prompted — it is stored encrypted, never in code
```

### 4. Get your Worker URL

After deployment, Wrangler prints:
```
Published groq-proxy (x.xx sec)
  https://groq-proxy.<your-subdomain>.workers.dev
```

Copy that URL.

### 5. Update the Flutter app

Open `ai_tools_hub/lib/config/api_config.dart` and replace the placeholder:

```dart
const String groqProxyUrl = 'https://groq-proxy.<your-subdomain>.workers.dev';
```

### 6. Test the Worker

```bash
curl -X POST https://groq-proxy.<your-subdomain>.workers.dev \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-3.3-70b-versatile",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 50
  }'
```

Expected: JSON response with `choices[0].message.content`.

## Security notes

- The Groq API key is stored in Cloudflare's encrypted secret store — never in source code or the APK.
- The Worker only forwards POST requests; all other methods return 405.
- For production, restrict `Access-Control-Allow-Origin` to your app's domain or remove CORS headers entirely (mobile apps don't need them).
- Consider adding a shared secret header between the app and Worker to prevent unauthorized use of your Worker URL.
