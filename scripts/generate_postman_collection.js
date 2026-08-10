// Orients Postman collection generator.
// Parses every *Controller.java + key request DTOs, emits a professional
// collection with real bodies, envelope examples, auth flow and variables.
const fs = require('fs');
const path = require('path');

const ROOT = 'E:/syed_moiz_ali/orientmobileapplication';
const BE = path.join(ROOT, 'orient-workshop-backend');
const OUT = path.join(ROOT, 'postman');

function listControllers() {
  const out = [];
  const walk = (dir) => {
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      const p = path.join(dir, e.name);
      if (e.isDirectory()) walk(p);
      else if (e.name.endsWith('Controller.java')) out.push(p);
    }
  };
  walk(path.join(BE, 'orient-advisor', 'src', 'main', 'java'));
  for (const mod of ['orient-auth','orient-crm','orient-customer','orient-gateway','orient-media','orient-owner','orient-supervisor','orient-sync','orient-technician','orient-whatsapp']) {
    walk(path.join(BE, mod, 'src', 'main', 'java'));
  }
  return out;
}

function cleanPath(p) {
  if (!p) return '';
  let s = p.trim();
  s = s.replace(/^path\s*=\s*/, '').replace(/^value\s*=\s*/, '');
  s = s.replace(/^"(.*)"$/, '$1');
  return s.trim();
}

function parseFile(file) {
  const src = fs.readFileSync(file, 'utf8');
  const lines = src.split(/\r?\n/);
  let base = '';
  let item = null;
  const endpoints = [];
  const classIdx = src.indexOf('public class');
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    const rm = line.match(/@RequestMapping\(\s*(?:value\s*=\s*)?"([^"]*)"\)/);
    if (rm && i < classIdx) { base = cleanPath(rm[1]); continue; }
    const m = line.match(/@(Get|Post|Put|Delete|Patch)Mapping\b(.*)$/);
    if (m) {
      if (item) endpoints.push(item);
      const verb = m[1].toUpperCase();
      // extract the path from the optional args, ignoring keyword args
      let p = '';
      const args = m[2] || '';
      if (args.trim()) {
        const cleaned = args
          .replace(/\b(consumes|produces|params|headers|method|name)\s*=\s*(?:\{[^}]*\}|"[^"]*"|\w+)/g, '')
          .replace(/\b(consumes|produces|params|headers|method|name)\s*=\s*/g, '');
        const q = cleaned.match(/"([^"]+)"/);
        if (q) p = q[1];
      }
      item = { verb, path: cleanPath(p), line: i, methodName: '', body: null, params: [] };
      // find this method's signature (starts with 'public') — scan only the
      // signature lines (up to the opening brace), never into the body
      let j = i + 1;
      let sigStart = -1;
      while (j < Math.min(i + 12, lines.length)) {
        const sl = lines[j].trim();
        if (/^public\s+/.test(sl) && /\(/.test(sl)) { sigStart = j; break; }
        j++;
      }
      if (sigStart >= 0) {
        const fn = lines[sigStart].match(/public\s+[\w<>\[\],?.\s]+\s+(\w+)\s*\(/);
        if (fn) item.methodName = fn[1];
        j = sigStart;
        while (j < Math.min(sigStart + 10, lines.length)) {
          const sl = lines[j].trim();
          const rb = sl.match(/@RequestBody\s+([\w<>]+)\s+\w+/);
          if (rb) item.body = rb[1].replace(/[<>]/g, '_');
          const pv = sl.match(/@PathVariable\(\s*"([^"]+)"\s*\)\s+[\w<>]+/);
          if (pv) item.params.push({ kind: 'path', name: pv[1] });
          const qp = sl.match(/@RequestParam\(\s*(?:value\s*=\s*)?"([^"]+)"\s*(?:,\s*defaultValue\s*=\s*"([^"]*)")?\s*\)/);
          if (qp) item.params.push({ kind: 'query', name: qp[1], def: qp[2] || '' });
          const pq = sl.match(/@RequestParam\s+[\w<>\[\]]+\s+(\w+)/);
          if (pq && !item.params.find(p => p.name === pq[1])) item.params.push({ kind: 'query', name: pq[1], def: '' });
          const pr = sl.match(/@RequestParam\(\s*required\s*=\s*\w+\s*\)\s+[\w<>\[\]]+\s+(\w+)/);
          if (pr && !item.params.find(p => p.name === pr[1])) item.params.push({ kind: 'query', name: pr[1], def: '' });
          j++;
          if (sl.endsWith('{') && sl.includes(')')) break;
        }
      }
    }
  }
  if (item) endpoints.push(item);
  // replace {} path vars with :name for postman
  for (const ep of endpoints) {
    ep.postmanPath = base + '/' + ep.path;
    ep.postmanPath = ep.postmanPath.replace(/\/\//g, '/');
    ep.postmanPath = ep.postmanPath.replace(/\{([^}]+)\}/g, ':$1');
    ep.postmanPath = ep.postmanPath.replace(/\/$/, '') || '/';
  }
  const fileName = path.basename(file, '.java');
  return { fileName, endpoints };
}

// ---- DTO field extractor (for body generation) ----
const dtoCache = {};
function dtoFields(typeName) {
  if (dtoCache[typeName]) return dtoCache[typeName];
  const walk = (dir, acc) => {
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      const p = path.join(dir, e.name);
      if (e.isDirectory()) walk(p, acc);
      else if (e.name === typeName + '.java') acc.push(p);
    }
  };
  const found = [];
  for (const mod of ['orient-advisor','orient-auth','orient-crm','orient-customer','orient-gateway','orient-owner','orient-supervisor','orient-technician']) {
    walk(path.join(BE, mod, 'src', 'main', 'java'), found);
  }
  let fields = null;
  if (found.length) {
    const src = fs.readFileSync(found[0], 'utf8');
    fields = [];
    for (const m of src.matchAll(/private\s+([\w<>]+)\s+(\w+);/g)) {
      fields.push({ type: m[1], name: m[2] });
    }
  }
  dtoCache[typeName] = fields;
  return fields;
}

function sampleValue(type) {
  const t = type.replace(/^[\w.]+\s*\./, '');
  if (/String/.test(t)) return 'string';
  if (/Long|Integer|int|long|BigDecimal|Double|Float/.test(t)) return 0;
  if (/Boolean/.test(t)) return true;
  if (/List|Set|\[\]/.test(t)) return [];
  if (/Map/.test(t)) return {};
  if (/LocalDate|LocalDateTime|Date/.test(t)) return '2026-08-10T09:00:00';
  return 'string';
}

function buildBody(dto) {
  const fields = dtoFields(dto);
  if (!fields || !fields.length) return null;
  const obj = {};
  for (const f of fields.slice(0, 14)) obj[f.name] = sampleValue(f.type);
  return JSON.stringify(obj, null, 2);
}

// curated realistic bodies for the most-used DTOs (frontend devs need these)
const curated = {
  SendOtpRequest: { type: 'sms', phone: '0501234567' },
  VerifyOtpRequest: { type: 'sms', phone: '0501234567', otp: '123456' },
  CreateBookingRequest: { vehicleId: '1', vehicleName: 'Toyota Camry', plateNumber: 'ABC-123', serviceType: 'Full Service', bookingDate: '2026-08-12T10:00:00', notes: 'Please check the AC too' },
  BreakdownRequest: { vehicleName: 'Nissan Patrol', plateNumber: 'XYZ-999', issue: 'Engine won\'t start', location: 'Sheikh Zayed Road, Exit 24', phone: '0501234567' },
  AddVehicleRequest: { brand: 'Toyota', model: 'Camry', plateNumber: 'ABC-123', vin: '4T1BF1FK4EU123456', color: 'White', year: 2021, mileage: '42500', lastService: '2026-01-15', nextDue: '2026-09-15' },
  DeviceTokenRequest: { token: 'fcm-device-token-abc123', platform: 'android' },
  FeedbackRequest: { jobCardRef: 'JC-123', rating: 5, comments: 'Great service, on time!', category: 'service_quality' },
  CreateBookingEstimateRequest: { jobCardId: '1', serviceName: 'Oil Change', quantity: 1, unitPrice: 120.0 },
  AssignAdvisorRequest: { advisorId: 2 },
  AssignTechnicianRequest: { technicianId: 3 },
  QcReviewRequest: { action: 'approve', checklistPassed: true, notes: 'All work verified', rejectReason: '' },
  WorkAssignmentRequest: { description: 'Change engine oil', technicianName: 'Mohammed', deadline: '2026-08-11' },
  RecordPaymentRequest: { invoiceId: 1, amount: 355.0, method: 'card', reference: 'POS-REF-001' },
  UpdateStockRequest: { quantity: 42, note: 'Received from supplier' },
  CreatePurchaseOrderRequest: { supplierId: 1, items: [{ partId: 1, quantity: 10, unitCost: 25.0 }], expectedDelivery: '2026-08-15' },
  CreateTeamMemberRequest: { name: 'John Smith', role: 'advisor', phone: '0501234567', branchId: 1 },
  UpdateTeamMemberRequest: { role: 'supervisor', isActive: true },
  WebhookSubscriptionRequest: { url: 'https://example.com/hooks/workshop', events: ['booking.created', 'job.completed'] },
  CreateApiKeyRequest: { name: 'Billing integration', scopes: ['invoices.read', 'payments.write'] },
  SubscriptionRequest: { plan: 'pro', billingCycle: 'monthly', seats: 10 },
  CreateSupportTicketRequest: { subject: 'Cannot reset password', message: 'Please help', priority: 'high' },
  SyncOperationRequest: { entityType: 'booking', entityId: 'BK-001', changeType: 'create', payload: { serviceType: 'Full Service' } },
  CreateReminderRequest: { customerName: 'Ahmed', vehicleId: '1', task: 'Call for service due', dueDate: '2026-08-15', priority: 'high' },
};

function bodyFor(ep) {
  if (!ep.body) return null;
  if (curated[ep.body]) return JSON.stringify(curated[ep.body], null, 2);
  return buildBody(ep.body);
}

// ---- response example ----
function exampleFor(ep, verb) {
  const envelope = (data) => ({ code: 200, message: 'Success', data, timestamp: 1754300000000 });
  let data;
  if (verb === 'GET') {
    data = ep.path.includes('{') || /profile|me|summary|detail|status|health|version/i.test(ep.path) ? {} : [];
  } else {
    data = { id: 1 };
  }
  return JSON.stringify(envelope(data), null, 2);
}

// ---- build collection ----
const folders = {};
function folder(name) {
  if (!folders[name]) folders[name] = { name, item: [] };
  return folders[name];
}

const folderByFile = {
  AuthController: '01 - Auth',
  HealthController: '00 - System', ApiVersionController: '00 - System', BranchController: '00 - System',
  AdvisorDashboardController: '02 - Advisor', JobCardController: '02 - Advisor', InspectionController: '02 - Advisor',
  RepairOrderController: '02 - Advisor', CustomerApprovalController: '02 - Advisor', ApprovalController: '02 - Advisor',
  AdvisorCheckInController: '02 - Advisor', AutoPriceController: '02 - Advisor', AdvisorInventoryController: '02 - Advisor',
  AdvisorWorkItemController: '02 - Advisor', ReminderController: '02 - Advisor', ReportController: '02 - Advisor', SearchController: '02 - Advisor',
  BookingController: '03 - Customer', CustomerController: '03 - Customer', VehicleController: '03 - Customer',
  BreakdownController: '03 - Customer', FeedbackController: '03 - Customer', ServiceTrackingController: '03 - Customer',
  CustomerTicketController: '03 - Customer', DataPrivacyController: '03 - Customer', DeviceTokenController: '03 - Customer',
  NotificationController: '03 - Customer', CustomerInvoiceController: '03 - Customer',
  SupervisorDashboardController: '04 - Supervisor', SupervisorQueueController: '04 - Supervisor',
  WorkAssignmentController: '04 - Supervisor', StaffNotificationController: '04 - Supervisor', ReferenceDataController: '04 - Supervisor',
  TechnicianJobController: '05 - Technician', WorkItemController: '05 - Technician', TaskController: '05 - Technician',
  AttendanceController: '05 - Technician', ProductivityController: '05 - Technician', TechnicianProfileController: '05 - Technician',
  TechnicianRequestController: '05 - Technician',
  OwnerDashboardController: '06 - Owner', PaymentController: '06 - Owner', InventoryController: '06 - Owner',
  WarrantyController: '06 - Owner', TeamController: '06 - Owner', SubscriptionController: '06 - Owner',
  ApiKeyController: '06 - Owner', WebhookController: '06 - Owner', InvoicePdfController: '06 - Owner',
  OwnerTicketController: '06 - Owner',
  CrmController: '07 - CRM',
  SyncController: '08 - Sync', MediaController: '08 - Sync',
  WhatsAppController: '09 - WhatsApp',
};

const files = listControllers();
let total = 0;
for (const f of files) {
  const parsed = parseFile(f);
  const fName = parsed.fileName;
  for (const ep of parsed.endpoints) {
    total++;
    const body = bodyFor(ep);
    const example = exampleFor(ep, ep.verb);
    const desc = [
      '**Method:** ' + ep.methodName + '()',
      '**Requires auth:** Bearer token (roles apply)',
      '**Body:** ' + (body ? '```json\n' + body + '\n```' : 'none'),
    ].join('\n\n');
    const item = {
      name: `${ep.verb} ${ep.postmanPath}`,
      request: {
        method: ep.verb,
        header: [{ key: 'Content-Type', value: 'application/json' }],
        url: { raw: `{{baseUrl}}${ep.postmanPath}`, host: ['{{baseUrl}}'], path: ep.postmanPath.split('/').filter(Boolean) },
        description: desc,
      },
      response: [{
        name: 'Success (200)',
        originalRequest: { method: ep.verb, url: `{{baseUrl}}${ep.postmanPath}` },
        status: 'OK', code: 200,
        header: [{ key: 'Content-Type', value: 'application/json' }],
        body: example,
        _postman_previewlanguage: 'json',
      }],
    };
    if (body) item.request.body = { mode: 'raw', raw: body, options: { raw: { language: 'json' } } };
    for (const p of ep.params) {
      if (p.kind === 'query') {
        if (!item.request.url.query) item.request.url.query = [];
        if (!item.request.url.query.find(q => q.key === p.name)) item.request.url.query.push({ key: p.name, value: p.def || '{{' + p.name + '}}' });
      }
    }
    folder(folderByFile[fName] || 'Other').item.push(item);
  }
}

const order = ['00 - System', '01 - Auth', '02 - Advisor', '03 - Customer', '04 - Supervisor', '05 - Technician', '06 - Owner', '07 - CRM', '08 - Sync', '09 - WhatsApp', 'Other'];
const items = order.map(n => folders[n]).filter(Boolean);

// auth pre-request: verify-otp saves token
const authFolder = folders['01 - Auth'];
for (const it of authFolder.item) {
  if (it.name.includes('verify-otp')) {
    it.event = [{
      listen: 'test',
      script: { type: 'text/javascript', exec: [
        'const json = pm.response.json();',
        'if (json && json.data && json.data.token) {',
        '  pm.collectionVariables.set(\'token\', json.data.token);',
        '  pm.collectionVariables.set(\'userId\', String(json.data.userId || \'\'));',
        '  console.log(\'Token saved (expires with session).\');',
        '}',
      ] },
    }];
  }
}

const collection = {
  info: {
    name: 'Orient Workshop API',
    description: [
      '# Orient Workshop — Complete API Collection',
      '',
      'Professional collection covering **ALL** endpoints across the monorepo (auth, advisor, customer, supervisor, technician, owner, CRM, sync, media, WhatsApp).',
      '',
      '## Getting started',
      '1. Import **both** files into Postman (collection + environment).',
      '2. Open the **Orient Workshop (Local)** environment → set `baseUrl` to your gateway (default `http://localhost:8080/api/v1`).',
      '3. Under **01 - Auth**: run *Send OTP* → *Verify OTP* — the test script stores the JWT into the `token` variable automatically.',
      '4. Every other request uses `Authorization: Bearer {{token}}`.',
      '5. Dev profile OTP is fixed: `123456`. In production, the OTP is delivered via your SMS provider.',
      '',
      '## Variables',
      '| Variable | Purpose |',
      '|---|---|',
      '| `baseUrl` | API root (e.g. http://localhost:8080/api/v1) |',
      '| `token` | JWT — set automatically by the Verify OTP test script |',
      '| `phone` / `otp` | Login credentials (dev: otp=123456) |',
      '| `apiKey` | For API-key secured calls (`X-API-Key` header) |',
      '',
      '## Response envelope',
      'Every endpoint returns: `{"code": 200, "message": "Success", "data": {...}, "timestamp": ...}`',
      '',
      '**Role requirements** (JWT role is re-validated per request): owner, advisor, supervisor, technician, customer, crmDashboard, admin.',
      '',
      '## Notes',
      '- Rate limiting: 100 req/min per IP (auth endpoints stricter). Load tests must raise `--app.rate-limit.*`.',
      '- Date format: `yyyy-MM-dd\'T\'HH:mm:ss` (UTC).',
      '- File uploads: `multipart/form-data`, max 50MB.',
    ].join('\n'),
    schema: 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
  },
  auth: { type: 'bearer', bearer: [{ key: 'token', value: '{{token}}', type: 'string' }] },
  variable: [
    { key: 'baseUrl', value: 'http://localhost:8080/api/v1', type: 'string' },
    { key: 'token', value: '', type: 'string' },
    { key: 'phone', value: '0501234567', type: 'string' },
    { key: 'otp', value: '123456', type: 'string' },
    { key: 'apiKey', value: '', type: 'string' },
    { key: 'id', value: '1', type: 'string' },
    { key: 'date', value: '2026-08-10', type: 'string' },
    { key: 'serviceType', value: '', type: 'string' },
    { key: 'branchId', value: '1', type: 'string' },
    { key: 'page', value: '1', type: 'string' },
    { key: 'limit', value: '20', type: 'string' },
    { key: 'status', value: '', type: 'string' },
    { key: 'search', value: '', type: 'string' },
  ],
  item: items,
};

fs.mkdirSync(OUT, { recursive: true });
fs.writeFileSync(path.join(OUT, 'Orient Workshop.postman_collection.json'), JSON.stringify(collection, null, 2));

const environment = {
  name: 'Orient Workshop (Local)',
  values: [
    { key: 'baseUrl', value: 'http://localhost:8080/api/v1', enabled: true },
    { key: 'token', value: '', enabled: true },
    { key: 'phone', value: '0501234567', enabled: true },
    { key: 'otp', value: '123456', enabled: true },
    { key: 'apiKey', value: '', enabled: true },
    { key: 'id', value: '1', enabled: true },
    { key: 'date', value: '2026-08-10', enabled: true },
    { key: 'serviceType', value: '', enabled: true },
    { key: 'branchId', value: '1', enabled: true },
    { key: 'page', value: '1', enabled: true },
    { key: 'limit', value: '20', enabled: true },
    { key: 'status', value: '', enabled: true },
    { key: 'search', value: '', enabled: true },
  ],
  _postman_variable_scope: 'environment',
};
fs.writeFileSync(path.join(OUT, 'Orient Workshop.postman_environment.json'), JSON.stringify(environment, null, 2));

console.log('TOTAL ENDPOINTS:', total, '| files:', files.length);
console.log('Output:', OUT);
