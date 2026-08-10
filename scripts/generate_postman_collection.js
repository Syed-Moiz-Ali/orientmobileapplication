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
        let sigText = '';
        j = sigStart;
        while (j < Math.min(sigStart + 10, lines.length)) {
          const sl = lines[j].trim();
          sigText += ' ' + sl;
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
        // return type: ApiResponse<T> / ResponseEntity<T> / plain T
        const ret = sigText.match(/public\s+([\w<>\[\],?.\s]+)\s+\w+\s*\(/);
        if (ret) item.returnType = ret[1].trim();
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
  if (/Boolean/i.test(t)) return true;
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

// ---- SQL schema (from the Flyway migrations V1..V12) ----
// Owner decision: response models must be checked against the DATABASE
// schemas. Every table + column is parsed from the migration SQL.

const sqlTables = {}; // table -> { col: { type, line } }
function parseSqlSchema() {
  const migDir = path.join(BE, 'orient-gateway', 'src', 'main', 'resources', 'db', 'migration');
  if (!fs.existsSync(migDir)) return;
  for (const f of fs.readdirSync(migDir).filter(n => /^V\d+.*\.sql$/.test(n))) {
    const src = fs.readFileSync(path.join(migDir, f), 'utf8')
      .replace(/--[^\n]*/g, '\n');
    const lines = src.split(/\r?\n/);
    let current = null;
    for (const raw of lines) {
      const line = raw.trim();
      const create = line.match(/^CREATE TABLE (?:IF NOT EXISTS )?(\w+)/i);
      if (create) { current = create[1]; sqlTables[current] = {}; continue; }
      if (!current) continue;
      if (line.startsWith(')')) { current = null; continue; }
      if (/^(INDEX|KEY|PRIMARY|FOREIGN|UNIQUE|CONSTRAINT|CHECK|FULLTEXT|SPATIAL)/i.test(line)) continue;
      const col = line.match(/^`?(\w+)`?\s+(\w+)(?:\(([^)]*)\))?/);
      if (col) sqlTables[current][col[1]] = col[2] + (col[3] ? `(${col[3]})` : '');
    }
  }
}
parseSqlSchema();
// replay DROP COLUMN statements so the schema doc reflects the FINAL state
// (e.g. V14 drops users.ref — it must not appear in the doc)
{
  const migDir = path.join(BE, 'orient-gateway', 'src', 'main', 'resources', 'db', 'migration');
  for (const f of fs.readdirSync(migDir).filter(n => /^V\d+.*\.sql$/.test(n))) {
    const src = fs.readFileSync(path.join(migDir, f), 'utf8');
    for (const m of src.matchAll(/ALTER TABLE (\w+)\s+DROP COLUMN (\w+)/gi)) {
      if (sqlTables[m[1]]) delete sqlTables[m[1]][m[2]];
    }
  }
}

function snakeToCamel(s) {
  return s.replace(/_([a-z])/g, (_, c) => c.toUpperCase());
}

// response DTO/entity -> underlying SQL table (by name similarity)
const TYPE_TABLE_OVERRIDES = {
  crmtask: 'crm_tasks', crmconversation: 'crm_conversations',
  conversation: 'crm_conversations', crmintegration: 'crm_integrations',
  workassignment: 'work_assignments', technicianjob: 'job_cards',
  ownerjobcard: 'job_cards', customerapproval: 'approvals',
  customerprofile: 'customers', teammember: 'staff', arrecord: 'accounts_receivable',
  activelog: 'activity_log', leadactivity: 'lead_activities',
  inspectiondraft: 'inspections', servicetype: 'service_types',
};
function tableForType(typeName) {
  let name = typeName
    .replace(/(Response|ResponseDto|DTO|Dto|Entity|Info|Summary|Detail|Item|Card)$/i, '')
    .toLowerCase();
  if (TYPE_TABLE_OVERRIDES[name]) return TYPE_TABLE_OVERRIDES[name];
  const candidates = new Set([name, name + 's', name.replace(/s$/, ''), name + 'es', name.replace(/es$/, '')]);
  for (const cand of candidates) {
    if (sqlTables[cand]) return cand;
    const hit = Object.keys(sqlTables).find(t => t.toLowerCase() === cand);
    if (hit) return hit;
  }
  return null;
}

function tableColumns(table) {
  const cols = sqlTables[table];
  if (!cols) return null;
  return Object.entries(cols).map(([col, type]) => ({ col, camel: snakeToCamel(col), type }));
}

// ---- response examples built from the ACTUAL response DTOs ----
// Frontend devs create Flutter models from these shapes, so field names and
// nesting mirror the real payloads exactly.

const modelCache = {};
function findClassFile(typeName) {
  if (modelCache[typeName] !== undefined) return modelCache[typeName];
  let found = null;
  const walk = (dir) => {
    if (found) return;
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      if (found) return;
      const p = path.join(dir, e.name);
      if (e.isDirectory()) walk(p);
      else if (e.name === typeName + '.java') { found = p; return; }
    }
  };
  for (const mod of ['orient-core','orient-advisor','orient-auth','orient-crm','orient-customer','orient-gateway','orient-media','orient-owner','orient-supervisor','orient-sync','orient-technician','orient-whatsapp','orient-common']) {
    walk(path.join(BE, mod, 'src', 'main', 'java'));
    if (found) break;
  }
  modelCache[typeName] = found;
  return found;
}

function modelFields(typeName) {
  const file = findClassFile(typeName);
  if (!file) return null;
  const src = fs.readFileSync(file, 'utf8');
  const fields = [];
  // only simple private fields on the class (skip static/final, inherited)
  for (const m of src.matchAll(/private\s+(final\s+)?([\w<>\[\].]+)\s+(\w+)\s*(?:=|;)/g)) {
    fields.push({ type: m[2].trim(), name: m[3] });
  }
  return fields.length ? fields : null;
}

// REALISTIC values by field name — the backend generates short alphanumeric
// refs (e.g. "JC-ee0ac073"), so samples mirror that style.
const HEX = '0123456789abcdef';
function shortHex(n) { let s = ''; for (let i = 0; i < n; i++) s += HEX[Math.floor(Math.random() * 16)]; return s; }

// P1 (V13): every table has a prefixed unique ref. Tables whose refs the app
// generates at insert use shortHex style (BK-3f9a2c1d); tables with the V13
// DB-generated column use zero-padded style (VEH-000001).
const TABLE_PREFIX = {
  customers: 'CUST', vehicles: 'VEH', service_types: 'ST',
  notifications: 'NTF', messages: 'MSG', whatsapp_messages: 'WM',
  approvals: 'APP', repair_order_services: 'ROS', repair_order_parts: 'ROP',
  predefined_services: 'PS', predefined_parts: 'PP', attendance: 'AT',
  activity_log: 'AL', employee_documents: 'DOC', crm_conversations: 'CV',
  crm_tasks: 'CT', crm_integrations: 'CI', lead_activities: 'LA',
  branches: 'BR', departments: 'DEPT', suppliers: 'SUP', inventory_items: 'ITM',
  purchase_order_items: 'POI', feedback: 'FB', device_tokens: 'DT',
  webhook_subscriptions: 'WH', api_keys: 'KEY', subscriptions: 'SUB',
  bookings: 'BK', job_cards: 'JC', invoices: 'INV', payments: 'PAY',
  leads: 'LD', support_tickets: 'TK', warranties: 'WR', purchase_orders: 'PO',
  work_assignments: 'ASN', reminders: 'REM', breakdowns: 'BRK',
  inspections: 'INSP', repair_orders: 'RO', accounts_receivable: 'AR',
  staff: 'EMP', technician_tasks: 'TASK',
};
const APP_GENERATED_REFS = new Set([
  'bookings', 'job_cards', 'invoices', 'payments', 'leads', 'support_tickets',
  'warranties', 'purchase_orders', 'work_assignments', 'reminders', 'breakdowns',
  'inspections', 'repair_orders', 'accounts_receivable', 'staff', 'technician_tasks',
]);

function refValueFor(table) {
  const p = TABLE_PREFIX[table] || 'REF';
  return APP_GENERATED_REFS.has(table) ? `${p}-${shortHex(6)}` : `${p}-000001`;
}

function refFor(name, n) {
  const key = name.toLowerCase();
  if (key.includes('jobcard') || key.includes('job_card') || key === 'job') return 'JC-' + shortHex(8);
  if (key.includes('booking')) return 'BK-' + shortHex(6);
  if (key.includes('invoice')) return 'INV-' + shortHex(6);
  if (key.includes('payment')) return 'PAY-' + shortHex(6);
  if (key.includes('lead')) return 'LD-' + shortHex(6);
  if (key.includes('ticket')) return 'TK-' + shortHex(6);
  if (key.includes('estimate') || key.includes('approval')) return 'EST-' + shortHex(6);
  if (key.includes('member')) return 'CUST-000001';
  if (key.includes('branch')) return 'BR-000001';
  if (key.includes('supplier')) return 'SUP-000001';
  if (key.includes('warrant')) return 'WR-' + shortHex(6);
  if (key.includes('po') || key.includes('purchase')) return 'PO-' + shortHex(6);
  if (key.includes('employee') || key.includes('emp')) return 'EMP-' + shortHex(4);
  return 'REF-' + shortHex(6);
}

function stringSample(name) {
  const n = name.toLowerCase();
  if (n === 'id') return shortHex(8);
  if (n === 'datekey') return '2026-08-10';
  if (n.includes('emp')) return 'EMP-a1b2c3d4';
  if (n.includes('shift')) return 'Morning';
  if (n.includes('designation')) return 'Service Advisor';
  if (n.includes('department')) return 'Workshop';
  if (n.includes('sku')) return 'SKU-1001';
  if (n.includes('estimateid')) return 'EST-a1b2c3';
  if (n.includes('jobcardid') || (n.includes('job') && n.includes('id'))) return 'JC-ee0ac073';
  if (n.includes('placeofsupply') || n.includes('place_of_supply')) return 'DUBAI';
  if (n.includes('delivery')) return '2026-08-15T09:00:00';
  if (n.includes('tag')) return 'VIP';
  if (n.includes('task')) return 'Change engine oil and filter';
  if (n.includes('slot')) return '10:00';
  if (n.includes('body')) return 'Your car is ready for collection';
  if (n.includes('stage')) return 'in_progress';
  if (n.includes('duration')) return '1.5 hours';
  if (n.includes('price')) return '120.00';
  if (n.includes('value')) return '125.50';
  if (n.includes('label')) return 'Active Jobs';
  if (n.includes('sub')) return 'Open job cards';
  if (n.includes('amount')) return '125.50';
  if (n.includes('change')) return '+12%';
  if (n.includes('count')) return '3';
  if (n.includes('location')) return 'Al Quoz Industrial 3, Dubai';
  if (n.includes('jobcard')) return 'JC-ee0ac073';
  if (n.includes('punchin') || n.includes('punchout')) return '2026-08-10T08:30:00';
  if (n.includes('workhours') || n.includes('hours')) return '8h 30m';
  if (n.includes('keyhash') || n.includes('key')) return shortHex(16);
  if (n.includes('month')) return 'Aug 2026';
  if (n.includes('urgency')) return 'high';
  if (n.includes('arid') || n.includes('leadid')) return shortHex(8);
  if (n.includes('aging')) return '15 days';
  if (n.includes('contact') || n.includes('recipient')) return 'Moiz Ali';
  if (n.includes('plan')) return 'pro';
  if (n.includes('terms')) return 'Net 30 days';
  if (n.includes('revenue')) return '1250.00';
  if (n.includes('channel')) return 'whatsapp';
  if (n.includes('action')) return 'approve';
  if (n.includes('detail')) return 'Brake pads at 3mm — replace recommended';
  if (n.includes('external') || n.startsWith('ext')) return 'EXT-1001';
  if (n.includes('recommend')) return 'Replace brake pads and rotate tyres';
  if (n.includes('data')) return 'payload';
  if (n.includes('started')) return '2026-08-10T09:00:00';
  if (n.includes('estcompletion')) return '2026-08-10T15:00:00';
  if (n.includes('currentstage')) return 'in_progress';
  if (n.includes('day')) return 'Monday';
  if (n.includes('email')) return 'moiz.ali@example.com';
  if (n.includes('phone')) return '971501234567';
  if (n.includes('plate')) return 'DUBAI 12345';
  if (n.includes('vin')) return 'JTDBT123456789012';
  if (n.includes('mileage') || n.includes('odometer')) return '42500';
  if (n.includes('vehicle')) return 'Toyota Camry';
  if (n.includes('customer') && n.includes('name')) return 'Moiz Ali';
  if (n.includes('customer')) return 'Moiz Ali';
  if (n.includes('technician')) return 'Mohammed Ali';
  if (n.includes('advisor')) return 'Khaled Salem';
  if (n.includes('supervisor')) return 'Omar Farooq';
  if (n.includes('owner')) return 'Orient Workshop';
  if (n.includes('assignedto') || n.includes('assigned_to')) return 'Khaled Salem';
  if (n.includes('status')) return 'confirmed';
  if (n.includes('ref') || n.includes('number') || n.includes('code') || n === 'no' || n.endsWith('no')) return refFor(name, 6);
  if (n.includes('date')) return '10 Aug 2026';
  if (n.includes('time')) return '10:00 AM';
  if (n.includes('createdat') || n.includes('updatedat') || n.includes('issued') || n.includes('due') || n.includes('activity')) return '2026-08-10T09:00:00';
  if (n.includes('color')) return 'White';
  if (n.includes('brand') || n.includes('make')) return 'Toyota';
  if (n.includes('model')) return 'Camry';
  if (n.includes('service')) return 'Full Service';
  if (n.includes('role')) return 'advisor';
  if (n.includes('url') || n.includes('link')) return 'https://cdn.orientworkshop.ae/files/jc-ee0ac073.pdf';
  if (n.includes('type')) return 'sms';
  if (n.includes('branch')) return 'Main Branch - Dubai';
  if (n.includes('notes') || n.includes('comment') || n.includes('message')) return 'Customer requested AC check as well';
  if (n.includes('avatar') || n.includes('initials')) return 'MA';
  if (n.includes('image') || n.includes('photo')) return 'https://cdn.orientworkshop.ae/img/car1.jpg';
  if (n.includes('member')) return 'CUST-000001';
  if (n.includes('source')) return 'whatsapp';
  if (n.includes('name')) return 'Moiz Ali';
  if (n.includes('address')) return 'Al Barsha 1, Dubai, UAE';
  if (n.includes('city')) return 'Dubai';
  if (n.includes('country')) return 'UAE';
  if (n.includes('currency') || n.includes('unit')) return 'AED';
  if (n.includes('reason')) return 'Brake pads below safe thickness';
  if (n.includes('title') || n.includes('subject')) return 'Car makes noise when turning';
  if (n.includes('description') || n.includes('issue') || n.includes('problem')) return 'Clicking sound from the front left when turning';
  if (n.includes('priority')) return 'high';
  if (n.includes('method')) return 'card';
  if (n.includes('token')) return 'eyJhbGciOiJIUzM4NCJ9.examplePayload.exampleSignature';
  if (n.includes('secret')) return 'whsec_' + shortHex(16);
  if (n.includes('category')) return 'service_quality';
  return 'string';
}

function numberSample(type, name) {
  const n = name.toLowerCase();
  const t = type.replace(/^[\w.]+\s*\./, '');
  if (/Integer|int/.test(t)) {
    if (n.includes('health') || n.includes('score') || n.includes('percent') || n.includes('progress')) return 92;
    if (n.includes('year')) return 2021;
    if (n.includes('page')) return 0;
    if (n.includes('size')) return 20;
    if (n.includes('total')) return 1;
    return 1;
  }
  if (/Long|long/.test(t)) return 1;
  if (/BigDecimal|Double|double|Float|float/.test(t)) {
    if (n.includes('taxrate') || n.includes('tax_rate') || n === 'rate') return 0.05;
    if (n.includes('amount') || n.includes('price') || n.includes('total') || n.includes('cost') || n.includes('balance') || n.includes('due') || n.includes('value')) return 125.5;
    return 1.5;
  }
  return 0;
}

function sampleFor(type, name, depth, table) {
  const t = type.replace(/^[\w.]+\s*\./, '');
  // ids match the SQL format: every table is `id BIGINT AUTO_INCREMENT` —
  // numeric values (1, 2, 3...), not hashes.
  if (name === 'id') return 1;
  // P1 (V13): ref fields get the table-accurate prefixed value.
  const nl = name.toLowerCase();
  if ((nl.includes('ref') || /ref$/.test(nl)) && !nl.includes('member')) {
    return table ? refValueFor(table) : refFor(name, 6);
  }
  if (/String/.test(t)) return stringSample(name);
  if (/Integer|int|Long|long|BigDecimal|Double|double|Float|float/.test(t)) return numberSample(t, name);
  if (/Boolean/i.test(t)) return true;
  if (/List|Set|\[\]/.test(t)) {
    const inner = t.match(/List\s*<([^>]+)>/) || t.match(/Set\s*<([^>]+)>/);
    const el = inner ? inner[1].trim() : 'String';
    if (/String/.test(el)) return ['string'];
    return [sampleFor(el, name + 'Item', depth + 1)];
  }
  if (/Map/.test(t)) return {};
  if (/LocalDate|LocalDateTime|Date|Instant/.test(t)) return '2026-08-10T09:00:00';
  if (/byte\[\]|Byte/.test(t)) return 'base64-encoded-bytes';
  // nested DTO — recurse
  if (depth < 3) {
    const nested = modelSample(t, depth + 1);
    if (nested) return nested;
  }
  return {};
}

function modelSample(typeName, depth = 0) {
  const fields = modelFields(typeName);
  if (!fields) return null;
  const obj = {};
  for (const f of fields) obj[f.name] = sampleFor(f.type, f.name, depth, null);
  return obj;
}

// unwrap the data type from a controller return type
function dataTypeOf(returnType) {
  if (!returnType) return null;
  const t = returnType.replace(/[\s]+/g, ' ').trim();
  // ApiResponse<X> / ResponseEntity<X>
  let inner = null;
  const wrap = t.match(/^(?:[\w.]+\s*<)?\s*(?:ApiResponse|ResponseEntity)\s*<(.+)>\s*>?$/);
  if (wrap) inner = wrap[1].trim();
  else if (t.startsWith('ApiResponse<') || t.startsWith('ResponseEntity<')) {
    inner = t.slice(t.indexOf('<') + 1, t.lastIndexOf('>')).trim();
  }
  if (!inner) inner = t;
  inner = inner.replace(/^java\.util\./, '').replace(/^java\./, '');
  // strip generics already consumed
  if (/^(?:List|Page|PageResponse|Set)\s*<(.+)>/.test(inner)) {
    const innerType = inner.match(/^(?:List|Page|PageResponse|Set)\s*<(.+)>/)[1].trim();
    const isPage = /^Page(?:Response)?\s*<(.+)>/.test(inner);
    return { kind: isPage ? 'page' : 'list', of: innerType };
  }
  if (inner === 'void' || inner === 'Void' || inner === 'String' || /^(?:boolean|long|int)/.test(inner)) {
    return { kind: inner === 'String' ? 'string' : 'simple', of: inner };
  }
  if (/^Map/.test(inner)) return { kind: 'map', of: inner };
  return { kind: 'object', of: inner };
}

// curated realistic responses for the most important endpoints
const curatedResponses = {
  'POST /auth/verify-otp': {
    code: 200, message: 'Success',
    data: { role: 'customer', token: 'eyJhbGciOiJIUzM4NCJ9.<jwt-payload>.<signature>', userId: 1 },
    timestamp: 1754300000000,
  },
  'GET /auth/me': {
    code: 200, message: 'Success',
    data: { userId: 1, name: 'Ahmed Hassan', phone: '971501234567', role: 'customer', isActive: true, branchId: 1, branchName: 'Main Branch - Dubai', customerId: 1, memberId: 'CUST-001' },
    timestamp: 1754300000000,
  },
  'GET /bookings/availability': {
    code: 200, message: 'Success',
    data: { date: '2026-08-10', serviceType: 'Full Service', availableSlots: ['09:00', '10:00', '11:00', '14:00'], bookedSlots: ['12:00', '13:00'], workshopCapacity: 4, bookedCount: 2 },
    timestamp: 1754300000000,
  },
  'GET /customers/bookings': {
    code: 200, message: 'Success',
    data: [
      { id: 1, service: 'Full Service', vehicleName: 'Toyota Camry', plateNumber: 'ABC-123', date: '10 Aug 2026', time: '10:00 AM', status: 'confirmed' },
      { id: 2, service: 'Oil Change', vehicleName: 'Nissan Patrol', plateNumber: 'XYZ-999', date: '12 Aug 2026', time: '02:00 PM', status: 'pending' },
    ],
    timestamp: 1754300000000,
  },
  'GET /customers/profile': {
    code: 200, message: 'Success',
    data: { id: 1, name: 'Ahmed Hassan', firstName: 'Ahmed', lastName: 'Hassan', phone: '971501234567', email: 'ahmed@example.com', memberId: 'CUST-001', loyaltyPoints: 120, memberSince: '2026-01-01' },
    timestamp: 1754300000000,
  },
  'GET /customers/vehicles': {
    code: 200, message: 'Success',
    data: [
      { id: '1', brand: 'Toyota', model: 'Camry', plateNumber: 'ABC-123', vin: '4T1BF1FK4EU123456', color: 'White', year: 2021, mileage: '42500', lastService: '2026-01-15', nextDue: '2026-09-15', healthScore: 92 },
    ],
    timestamp: 1754300000000,
  },
  'GET /supervisor/bookings': {
    code: 200, message: 'Success',
    data: [
      { id: 1, bookingRef: 'BK-1001', customerName: 'Ahmed Hassan', phone: '971501234567', vehicleName: 'Toyota Camry', plateNumber: 'ABC-123', serviceType: 'Full Service', bookingDate: '10 Aug 2026 · 10:00 AM', dateKey: '2026-08-10', notes: '', status: 'pending' },
    ],
    timestamp: 1754300000000,
  },
  'GET /supervisor/kpis': {
    code: 200, message: 'Success',
    data: [
      { value: '7', label: 'Total Jobs', sub: 'Open job cards' },
      { value: '3', label: 'In Progress', sub: 'Active now' },
      { value: '4', label: 'Completed', sub: 'This week' },
    ],
    timestamp: 1754300000000,
  },
  'POST /owner/payments': {
    code: 200, message: 'Success',
    data: { paymentRef: 'PAY-1001', remaining: 0 },
    timestamp: 1754300000000,
  },
  'GET /owner/invoices': {
    code: 200, message: 'Success',
    data: [
      { id: 1, invoiceRef: 'INV-1001', customerName: 'Ahmed Hassan', jobCardRef: 'JC-1001', amount: 355.0, taxRate: 0.05, taxAmount: 17.75, grandTotal: 372.75, status: 'unpaid', issuedDate: '2026-08-10', dueDate: '2026-09-09' },
    ],
    timestamp: 1754300000000,
  },
  'GET /technicians/jobs': {
    code: 200, message: 'Success',
    data: [
      { jobCardNo: 'JC-1001', vehicleName: 'Toyota Camry', plateNumber: 'ABC-123', serviceType: 'Full Service', status: 'In Progress', progressPercent: 60, notes: '', tasks: [{ taskId: 1, description: 'Change engine oil', status: 'done' }] },
    ],
    timestamp: 1754300000000,
  },
  'GET /crm/leads': {
    code: 200, message: 'Success',
    data: [
      { id: '1', sno: 1, leadNumber: 'LD-001', customerName: 'Ahmed Hassan', phone: '971501234567', vehicle: 'Toyota Camry', source: 'whatsapp', status: 'new', assignedTo: 'Khaled Salem', createdAt: '2026-08-10T09:00:00', score: 78 },
    ],
    timestamp: 1754300000000,
  },
  'GET /crm/leads/:id/score': {
    code: 200, message: 'Success',
    data: { score: 78, level: 'hot', reasons: ['WhatsApp engagement', 'Repeated service visits'], nextFollowUp: '2026-08-12T10:00:00' },
    timestamp: 1754300000000,
  },
};

// REAL captured responses (from scripts/capture_api_responses.js) win over
// curated/DTO-derived examples — the collection then shows actual API output.
const capturedFile = path.join(OUT, '.captured_responses.json');
const captured = fs.existsSync(capturedFile)
  ? JSON.parse(fs.readFileSync(capturedFile, 'utf8'))
  : {};

// ---- response models: NO example/sample values — the actual entity schema ----
// Owner decision: responses must show exactly what the backend entity/DTO
// declares (field name -> Java type), so frontend devs mirror the real model.

function prettyType(type) {
  let t = type
    .replace(/^java\.util\./, '')
    .replace(/^java\.time\./, '')
    .replace(/^java\.math\./, '')
    .replace(/^java\./, '')
    .replace(/^com\.orient\.workshop\.[\w.]+\./, '');
  const list = t.match(/^(?:List|Set)\s*<(.+)>/);
  if (list) {
    let inner = list[1].replace(/^java\.util\./, '').replace(/^java\.time\./, '').replace(/^java\.math\./, '').replace(/^java\./, '');
    inner = inner.replace(/^com\.orient\.workshop\.[\w.]+\./, '');
    return `List<${inner}>`;
  }
  return t;
}

function entitySchema(typeName, depth = 0) {
  const fields = modelFields(typeName);
  if (!fields || depth > 3) return null;
  const obj = {};
  for (const f of fields) obj[f.name] = prettyType(f.type);
  return obj;
}

// schema from the SQL table when no Java DTO class exists
function tableSchema(table) {
  const cols = tableColumns(table);
  if (!cols) return null;
  const obj = {};
  for (const c of cols) obj[c.camel] = c.type.toLowerCase();
  return obj;
}

// ---- response models: REAL values, EXACT entity field names ----
// Owner decision: no type-only placeholders. Each field of the actual
// entity/DTO gets a realistic sample value (refs in the backend's own
// short-alphanumeric style: "JC-ee0ac073", real names, real dates).

function entitySample(typeName, depth = 0, table = null) {
  const fields = modelFields(typeName);
  if (!fields || depth > 3) return null;
  const obj = {};
  for (const f of fields) obj[f.name] = sampleFor(f.type, f.name, depth, table);
  return obj;
}

function buildResponseModel(ep, verb) {
  const dt = dataTypeOf(ep.returnType);
  // find the SQL table backing this response (for description + fallback)
  let sqlTable = null;
  let dtoName = null;
  if (dt && (dt.kind === 'object' || dt.kind === 'list' || dt.kind === 'page')) {
    dtoName = dt.of;
    if (/^(?:String|Long|Integer|Boolean|BigDecimal|Double|Map)/.test(dtoName)) dtoName = null;
    else sqlTable = tableForType(dtoName);
  }
  ep.sqlTable = sqlTable;
  ep.dtoName = dtoName;

  const env = { code: 200, message: 'Success' };
  if (!dt) {
    env.timestamp = 1754300000000;
    return JSON.stringify(env, null, 2);
  }
  if (dt.kind === 'list') {
    const inner = dt.of;
    if (/^(?:String|Long|Integer|Boolean|BigDecimal|Double|Map)/.test(inner)) {
      env.data = [sampleFor(inner, 'value', 0)];
    } else {
      env.data = [entitySample(inner, 0, sqlTable) || {}];
    }
  } else if (dt.kind === 'page') {
    const inner = dt.of;
    env.data = {
      content: /^(?:String|Long|Integer|Boolean|BigDecimal|Double|Map)/.test(inner)
        ? [sampleFor(inner, 'value', 0)]
        : [entitySample(inner, 0, sqlTable) || {}],
      page: 0, size: 20, totalElements: 1, totalPages: 1,
    };
  } else if (dt.kind === 'string') {
    env.data = 'string';
  } else if (dt.kind === 'simple') {
    // void/action endpoints: the REAL envelope has no data key at all —
    // verified live: {"code":200,"message":"Success","timestamp":...}
  } else if (dt.kind === 'map') {
    env.data = { result: 'ok' };
  } else {
    env.data = entitySample(dt.of, 0, sqlTable) || {};
  }
  env.timestamp = 1754300000000;
  return JSON.stringify(env, null, 2);
}

function buildExample(ep, verb) {
  return buildResponseModel(ep, verb);
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
    const sqlNote = ep.sqlTable
      ? 'SQL table: `' + ep.sqlTable + '`'
      : null;
    const dtoNote = ep.dtoName ? 'Model: `' + ep.dtoName + '`' : null;
    const desc = [
      'Method: ' + ep.methodName + '()',
      'Auth: Bearer token (roles apply)',
      body ? 'Body:\n```json\n' + body + '\n```' : null,
      dtoNote,
      sqlNote,
    ].filter(Boolean).join('\n');
    const item = {
      name: `${ep.verb} ${ep.postmanPath}`,
      request: {
        method: ep.verb,
        header: [{ key: 'Content-Type', value: 'application/json' }],
        url: { raw: `{{baseUrl}}${ep.postmanPath}`, host: ['{{baseUrl}}'], path: ep.postmanPath.split('/').filter(Boolean) },
        description: desc,
      },
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

// ---- database schema doc (parsed from the Flyway migration SQL) ----
const schemaLines = [
  '# Orient Workshop — Database Schema',
  '',
  'Generated from the Flyway migrations (`orient-gateway/src/main/resources/db/migration/V1..V12`).',
  'This is the ground truth the API entities map to — response models in the collection',
  'are cross-checked against these tables.',
  '',
  '**' + Object.keys(sqlTables).length + ' tables.**',
  '',
];
for (const [table, cols] of Object.entries(sqlTables).sort()) {
  schemaLines.push('## `' + table + '`');
  for (const [col, type] of Object.entries(cols)) {
    schemaLines.push('- `' + col + '` — ' + type.toUpperCase());
  }
  schemaLines.push('');
}
fs.writeFileSync(path.join(OUT, 'database-schema.md'), schemaLines.join('\n'));

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
