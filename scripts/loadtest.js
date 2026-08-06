// Orient Workshop — k6 load test (P3, audit).
// Usage:  k6 run scripts/loadtest.js
// Targets the hottest endpoints with a 10% request-rate ramp.
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE = __ENV.BASE_URL || 'http://localhost:8080/api/v1';
// Login once, reuse the token for the whole test.
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

function login() {
  http.post(`${BASE}/auth/send-otp`, JSON.stringify({ type: 'sms', phone: OTP_PHONE }), {
    headers: { 'Content-Type': 'application/json' },
  });
  const r = http.post(`${BASE}/auth/verify-otp`,
    JSON.stringify({ type: 'sms', phone: OTP_PHONE, otp: '123456' }),
    { headers: { 'Content-Type': 'application/json' } });
  return r.json().data.token;
}

const TOKEN = login();
const headers = { Authorization: `Bearer ${TOKEN}` };

export default function () {
  const endpoints = [
    ['GET', `${BASE}/owner/dashboard/kpis`],
    ['GET', `${BASE}/owner/dashboard/sales-trend`],
    ['GET', `${BASE}/advisor/job-cards?page=1&limit=20`],
    ['GET', `${BASE}/supervisor/kpis`],
    ['GET', `${BASE}/crm/leads`],
    ['GET', `${BASE}/customers/profile`],
  ];
  const [method, url] = endpoints[Math.floor(Math.random() * endpoints.length)];

  const res = http.request(method, url, null, { headers });
  check(res, {
    'status is 2xx': (r) => r.status >= 200 && r.status < 300,
    'envelope ok': (r) => r.json('code') === 200,
  });
  sleep(0.2);
}
