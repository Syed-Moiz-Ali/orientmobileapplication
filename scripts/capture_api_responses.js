// Capture REAL responses from a running gateway and save them for the
// Postman collection generator. Usage (gateway must be up on localhost):
//   node scripts/capture_api_responses.js
// Output: postman/.captured_responses.json (gitignored) — merged by
// generate_postman_collection.js so examples are REAL API output.
const fs = require('fs');
const path = require('path');

const ROOT = 'E:/syed_moiz_ali/orientmobileapplication';
const BASE = process.env.API_BASE || 'http://localhost:8080/api/v1';
const COLL = path.join(ROOT, 'postman', 'Orient Workshop.postman_collection.json');
const OUT = path.join(ROOT, 'postman', '.captured_responses.json');

const PHONES = {
  owner: '0501234777',
  advisor: '0501111001',
  supervisor: '0501111002',
  crm: '0501111003',
  customer: '0501111004',
  technician: '0501111005',
};

async function login(phone) {
  await fetch(`${BASE}/auth/send-otp`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ type: 'sms', phone }),
  });
  const r = await fetch(`${BASE}/auth/verify-otp`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ type: 'sms', phone, otp: '123456' }),
  });
  const j = await r.json();
  return j?.data?.token;
}

function roleForPath(p) {
  if (p.startsWith('/owner') || p.startsWith('/branches') || p.startsWith('/sync') || p.startsWith('/version') || p.startsWith('/health') || p.startsWith('/customers/invoices')) return 'owner';
  if (p.startsWith('/supervisor') || p.startsWith('/work-assignments')) return 'supervisor';
  if (p.startsWith('/advisor') || p.startsWith('/inspections') || p.startsWith('/jobs')) return 'advisor';
  if (p.startsWith('/technician') || p.startsWith('/technicians')) return 'technician';
  if (p.startsWith('/crm')) return 'crm';
  if (p.startsWith('/whatsapp')) return null;
  return 'customer';
}

// value substitutions for path variables — try sensible real ids first
const VAR_VALUES = ['1', '2', 'JC-1', 'BK-1', 'INV-1', 'PAY-1', '3'];

function resolveUrl(raw) {
  let url = raw.replace('{{baseUrl}}', BASE);
  let missing = [];
  url = url.replace(/:([a-zA-Z]+)/g, (m, name) => {
    if (/^(id|bookingId|taskId|invoiceId|jobCardId|jobCardRef|breakdownId|estimateId|warrantyId|apiKeyId|webhookId|supplierId|partId|teamMemberId|ticketId|vehicleId|reminderId|leadId|paymentId|customerId|attachmentId|notificationId|userId|plan|documentId)$/.test(name)) {
      return '1';
    }
    missing.push(name);
    return m;
  });
  return { url, missing };
}

function buildQuery(url, item) {
  const q = item.request.url.query;
  if (!q || !q.length) return url;
  const parts = [];
  for (const kv of q) {
    if (!kv.key) continue;
    let v = kv.value || '';
    v = v.replace(/^\{\{|\}\}$/g, '');
    if (v === 'date') v = '2026-08-10';
    if (v === 'serviceType') v = 'Full Service';
    if (v === 'page' || v === 'limit') v = v === 'page' ? '1' : '20';
    if (v === 'status' || v === 'search') v = '';
    if (v === 'branchId' || v === 'id') v = '1';
    if (v.startsWith('{{')) continue;
    parts.push(`${kv.key}=${encodeURIComponent(v)}`);
  }
  return url + (parts.length ? '?' + parts.join('&') : '');
}

async function main() {
  const tokens = {};
  for (const [role, phone] of Object.entries(PHONES)) {
    tokens[role] = await login(phone);
    console.log(`login ${role}: ${tokens[role] ? 'OK' : 'FAIL'}`);
    if (!tokens[role]) { console.error('Aborting — login failed'); process.exit(1); }
  }

  const coll = JSON.parse(fs.readFileSync(COLL, 'utf8'));
  const captured = {};
  let ok = 0, fail = 0, skip = 0;

  for (const folder of coll.item) {
    for (const item of folder.item) {
      const raw = item.request.url.raw;
      const role = roleForPath(raw.replace('{{baseUrl}}', ''));
      if (!role) { skip++; continue; }
      const { url: resolved } = resolveUrl(raw);
      const url = buildQuery(resolved, item);
      const method = item.request.method;
      const headers = { 'Content-Type': 'application/json' };
      if (tokens[role]) headers['Authorization'] = `Bearer ${tokens[role]}`;

      let body;
      if (item.request.body?.raw) {
        try { body = JSON.parse(item.request.body.raw); } catch { body = null; }
      }

      try {
        const res = await fetch(url, {
          method,
          headers,
          body: body ? JSON.stringify(body) : undefined,
        });
        let text = await res.text();
        // try to pretty-print json
        try { text = JSON.stringify(JSON.parse(text), null, 2); } catch { /* keep raw */ }
        const key = `${method} ${raw.replace('{{baseUrl}}', '')}`;
        if (res.status >= 200 && res.status < 300) {
          captured[key] = { status: res.status, body: text };
          ok++;
          console.log(`✓ ${res.status} ${method} ${raw}`);
        } else {
          fail++;
          console.log(`✗ ${res.status} ${method} ${raw}`);
        }
      } catch (e) {
        fail++;
        console.log(`✗ ERR ${method} ${raw} — ${e.message}`);
      }
    }
  }

  fs.writeFileSync(OUT, JSON.stringify(captured, null, 2));
  console.log(`\nCAPTURED: ${ok} success responses | ${fail} non-2xx | ${skip} skipped (no auth)`);
  console.log('Saved:', OUT);
}

main().catch((e) => { console.error(e); process.exit(1); });
