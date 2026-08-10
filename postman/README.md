# Orient Workshop — Postman Collection

Professional API collection for the Orient Workshop platform — **209 endpoints** across all 10 modules, ready to hand to frontend developers.

## Files

| File | What it is |
|---|---|
| `Orient Workshop.postman_collection.json` | The complete collection (all endpoints, bodies, example responses) |
| `Orient Workshop.postman_environment.json` | Environment template (local dev defaults) |

## How to use

1. **Import both files** into Postman (Collection + Environment).
2. Select the **Orient Workshop (Local)** environment.
3. Under **01 - Auth** run:
   - `POST /auth/send-otp` → `POST /auth/verify-otp`
   - The verify-otp **test script stores the JWT automatically** into the `token` variable.
4. Every other request already carries `Authorization: Bearer {{token}}`.

> Dev profile OTP is fixed: `123456`. Production OTPs are delivered by your SMS provider.

## What's inside

- **10 folders**: System · Auth · Advisor · Customer · Supervisor · Technician · Owner · CRM · Sync · WhatsApp
- **Request bodies** for every POST/PUT endpoint — realistic samples (realistic values for the main flows: OTP login, booking, breakdown, check-in, QC review, payment, webhooks, API keys, subscription…; typed field samples for the rest)
- **Accurate response examples** — the shapes frontend devs build Flutter models from:
  - **Live responses** captured from the real running API (real envelope, real field names/nesting)
  - **Model examples** generated from the actual response DTO classes (for endpoints needing runtime state)
  - Each example is labelled so you know which is which
- **Query/path variables** (`{{date}}`, `{{page}}`, `:id`…) wired as Postman variables
- **Collection README** with the envelope contract, role requirements, rate-limit notes

## Refreshing the live examples

```bash
# 1. Start the gateway (dev profile)
# 2. Provision roles:
powershell -File scripts/provision_loadtest.ps1
# 3. Capture real responses from the running API:
node scripts/capture_api_responses.js
# 4. Regenerate the collection:
node scripts/generate_postman_collection.js
```

## Notes

- Rate limiting: **100 req/min per IP** (auth endpoints stricter) — load tests must raise `--app.rate-limit.*`.
- Date format: `yyyy-MM-dd'T'HH:mm:ss` (UTC).
- Uploads: `multipart/form-data`, max 50 MB.
- Role requirements (JWT role re-validated per request): `owner`, `advisor`, `supervisor`, `technician`, `customer`, `crmDashboard`, `admin`.
