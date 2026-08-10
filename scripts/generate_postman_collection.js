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

// realistic string samples by field name (so models/docs read naturally)
function stringSample(name) {
  const n = name.toLowerCase();
  if (n === 'id') return '1';
  if (n.includes('email')) return 'customer@example.com';
  if (n.includes('phone')) return '971501234567';
  if (n.includes('plate')) return 'ABC-123';
  if (n.includes('vehicle')) return 'Toyota Camry';
  if (n.includes('customer')) return 'Ahmed Hassan';
  if (n.includes('technician')) return 'Mohammed Ali';
  if (n.includes('advisor')) return 'Khaled Salem';
  if (n.includes('supervisor')) return 'Omar Farooq';
  if (n.includes('owner')) return 'Orient Workshop';
  if (n.includes('status')) return 'pending';
  if (n.includes('ref') || n.includes('number') || n.includes('code') || n.includes('no')) return 'REF-001';
  if (n.includes('date') || n.includes('time')) return '2026-08-10T09:00:00';
  if (n.includes('color')) return 'White';
  if (n.includes('brand') || n.includes('make')) return 'Toyota';
  if (n.includes('model')) return 'Camry';
  if (n.includes('service')) return 'Full Service';
  if (n.includes('role')) return 'customer';
  if (n.includes('url') || n.includes('link')) return 'https://example.com/file.pdf';
  if (n.includes('type')) return 'sms';
  if (n.includes('branch')) return 'Main Branch - Dubai';
  if (n.includes('notes') || n.includes('comment') || n.includes('message')) return 'Sample text';
  if (n.includes('avatar') || n.includes('image') || n.includes('photo')) return 'https://example.com/img.jpg';
  if (n.includes('name')) return 'Sample Name';
  return 'string';
}

function numberSample(type, name) {
  const n = name.toLowerCase();
  const t = type.replace(/^[\w.]+\s*\./, '');
  if (/Integer|int/.test(t)) {
    if (n.includes('percent') || n.includes('progress')) return 75;
    if (n.includes('year')) return 2021;
    return 1;
  }
  if (/Long|long/.test(t)) return 1;
  if (/BigDecimal|Double|double|Float|float/.test(t)) {
    if (n.includes('amount') || n.includes('price') || n.includes('total') || n.includes('cost') || n.includes('rate') || n.includes('balance') || n.includes('due')) return 125.5;
    return 1.5;
  }
  return 0;
}

function sampleFor(type, name, depth) {
  const t = type.replace(/^[\w.]+\s*\./, '');
  if (/String/.test(t)) return stringSample(name);
  if (/Integer|int|Long|long|BigDecimal|Double|double|Float|float/.test(t)) return numberSample(t, name);
  if (/Boolean/.test(t)) return true;
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
  for (const f of fields) obj[f.name] = sampleFor(f.type, f.name, depth);
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
  // strip generics already consumed
  if (/^(?:List|Page|Set)\s*<(.+)>/.test(inner)) {
    return { kind: 'list', of: inner.match(/^(?:List|Page|Set)\s*<(.+)>/)[1].trim() };
  }
  if (inner === 'void' || inner === 'Void' || inner === 'String' || /^(?:boolean|long|int|Map)/.test(inner)) {
    return { kind: inner === 'String' ? 'string' : 'simple', of: inner };
  }
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
};

// REAL captured responses (from scripts/capture_api_responses.js) win over
// curated/DTO-derived examples — the collection then shows actual API output.
const capturedFile = path.join(OUT, '.captured_responses.json');
const captured = fs.existsSync(capturedFile)
  ? JSON.parse(fs.readFileSync(capturedFile, 'utf8'))
  : {};

function buildExample(ep, verb) {
  const key = `${ep.verb} ${ep.postmanPath}`;
  const cap = captured[key];
  const capEmpty = cap && cap.status >= 200 && cap.status < 300 &&
    /"data"\s*:\s*(\[\]|\{\})/.test(cap.body);
  if (cap && !capEmpty && cap.status >= 200 && cap.status < 300) return cap.body;
  if (curatedResponses[key]) return JSON.stringify(curatedResponses[key], null, 2);
  const env = (data) => ({ code: 200, message: 'Success', data, timestamp: 1754300000000 });
  const dt = dataTypeOf(ep.returnType);
  let data;
  if (!dt) {
    data = verb === 'GET' ? {} : { id: 1 };
  } else if (dt.kind === 'list') {
    const inner = dt.of;
    if (inner === 'String' || /^(?:String|Long|Integer|Map)/.test(inner)) {
      data = [inner === 'String' ? 'string' : inner];
    } else {
      const sample = modelSample(inner);
      data = sample ? [sample] : [{}];
    }
  } else if (dt.kind === 'string') {
    data = 'string';
  } else if (dt.kind === 'simple') {
    data = {};
  } else {
    const sample = modelSample(dt.of);
    data = sample || {};
  }
  return JSON.stringify(env(data), null, 2);
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
    const example = buildExample(ep, ep.verb);
    const capKey = `${ep.verb} ${ep.postmanPath}`;
    const cap = captured[capKey];
    const isLive = !!cap && cap.status >= 200 && cap.status < 300 &&
      !(/"data"\s*:\s*(\[\]|\{\})/.test(cap.body));
    const liveEmpty = !!cap && cap.status >= 200 && cap.status < 300 && !isLive;
    const desc = [
      '**Method:** ' + ep.methodName + '()',
      '**Requires auth:** Bearer token (roles apply)',
      '**Body:** ' + (body ? '```json\n' + body + '\n```' : 'none'),
      '**Response:** ' + (isLive
        ? 'LIVE capture from the running API.'
        : liveEmpty
          ? 'Live call returned an empty dataset for this account — showing the model shape instead.'
          : 'Model example generated from the response DTO (the endpoint needs runtime state to return real data).'),
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
        name: isLive ? 'Live response (real API)' : (liveEmpty ? 'Example (live returned empty)' : 'Example response (from DTO)'),
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
