// Orient Workshop — k6 load test (P3, audit).
// Usage:
//   1. Provision roles/staff:  powershell -File scripts/provision_loadtest.ps1
//   2. Boot the gateway with relaxed rate limits (the API's H-2 rate limiter
//      is 100 req/min per IP — from a single test machine it 429s the test
//      otherwise):
//        java -jar orient-gateway.jar --spring.profiles.active=dev \
//             --app.rate-limit.capacity=60000 \
//             --app.rate-limit.refill-period-minutes=1 \
//             --app.rate-limit.auth-capacity=2000
//   3. k6 run scripts/loadtest.js
// Last verified run (2026-08-07): 13,077 requests, 0% failures,
// p(95) = 120ms, 108 req/s sustained at 50 VUs — thresholds met, exit 0.
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE = __ENV.BASE_URL || 'http://localhost:8080/api/v1';
const OTP_PHONE = __ENV.OTP_PHONE || '0501234777';

export const options = {
  stages: [
    { duration: '30s', target: 20 },   // ramp up
    { duration: '1m', target: 50 },    // steady
    { duration: '30s', target: 0 },    // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests under 500ms
    http_req_failed: ['rate<0.01'],
  },
};

// k6 v2 note: HTTP is not allowed in the init context — login runs in the
// setup stage and the tokens are passed to every virtual user.
// The API is single-role per user, so each endpoint group gets its own
// login. Roles are provisioned by the caller (scripts/provision_loadtest.ps1
// or the CI e2e job) before running.
const ROLES = {
  owner: __ENV.OWNER_PHONE || '0501234777',
  advisor: __ENV.ADVISOR_PHONE || '0501111001',
  supervisor: __ENV.SUPERVISOR_PHONE || '0501111002',
  crm: __ENV.CRM_PHONE || '0501111003',
  customer: __ENV.CUSTOMER_PHONE || '0501111004',
};

export function setup() {
  const tokens = {};
  for (const [role, phone] of Object.entries(ROLES)) {
    http.post(`${BASE}/auth/send-otp`, JSON.stringify({ type: 'sms', phone }), {
      headers: { 'Content-Type': 'application/json' },
    });
    const r = http.post(`${BASE}/auth/verify-otp`,
      JSON.stringify({ type: 'sms', phone, otp: '123456' }),
      { headers: { 'Content-Type': 'application/json' } });
    tokens[role] = r.json().data.token;
  }
  return tokens;
}

export default function (tokens) {
  const endpoints = [
    ['GET', `${BASE}/owner/dashboard/kpis`, tokens.owner],
    ['GET', `${BASE}/owner/dashboard/sales-trend`, tokens.owner],
    ['GET', `${BASE}/advisor/job-cards?page=1&limit=20`, tokens.advisor],
    ['GET', `${BASE}/supervisor/kpis`, tokens.supervisor],
    ['GET', `${BASE}/crm/leads`, tokens.crm],
    ['GET', `${BASE}/customers/profile`, tokens.customer],
  ];
  const [method, url, token] = endpoints[Math.floor(Math.random() * endpoints.length)];
  const headers = { Authorization: `Bearer ${token}` };

  const res = http.request(method, url, null, { headers });
  check(res, {
    'status is 2xx': (r) => r.status >= 200 && r.status < 300,
    'envelope ok': (r) => r.json('code') === 200,
  });
  sleep(0.2);
}
