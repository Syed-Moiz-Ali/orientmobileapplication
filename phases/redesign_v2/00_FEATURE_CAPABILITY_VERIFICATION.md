# 00 — Feature Capability & Backend Contract Verification (Redesign v2)

**Document ID:** `phases/redesign_v2/00_FEATURE_CAPABILITY_VERIFICATION.md`  
**Purpose:** Audit proposed prototype features against existing source code, Dio network APIs, and Hive offline storage  
**Standard:** ZERO FANTASY BACKENDS — Strict Classification into 4 Capability Tiers  
**Status:** BINDING ARCHITECTURAL VERIFICATION  

---

## 1. Classification Taxonomy

To prevent introducing features that cannot function or that require unapproved backend rewrites, every capability proposed by the visual prototypes is classified into one of four tiers:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   CAPABILITY CLASSIFICATION TIERS                      │
├──────┬────────────────────────────────┬────────────────────────────────┤
│ Tier │ Classification                 │ Production Rule                │
├──────┼────────────────────────────────┼────────────────────────────────┤
│ 1    │ Existing & Fully Supported     │ Wire directly to live backend. │
├──────┼────────────────────────────────┼────────────────────────────────┤
│ 2    │ Existing / Partially Supported │ Bind available data; handle    │
│      │                                │ missing fields gracefully.     │
├──────┼────────────────────────────────┼────────────────────────────────┤
│ 3    │ Visual-Only Presentation       │ Render using client-side       │
│      │ (Supported by Local Math/Data) │ computation or cached models.  │
├──────┼────────────────────────────────┼────────────────────────────────┤
│ 4    │ Requires New Backend / Domain  │ STRICTLY EXCLUDED from UI-only │
│      │ Functional Rewrite             │ phases unless approved.        │
└──────┴────────────────────────────────┴────────────────────────────────┘
```

---

## 2. Feature-by-Feature Capability Audit

### 2.1 Biometric Authentication (FaceID / Fingerprint)
- **Proposed Feature:** "Fast Pass via FaceID / Biometrics" button on Login.
- **Repository Audit:** No `local_auth` dependency exists in `packages/shared_auth/pubspec.yaml` or `apps/*/pubspec.yaml`.
- **Classification:** **Tier 4 (Requires New Backend / Native Dependency)**.
- **Production UI Resolution:** The login screen will feature standard high-trust credentials (Password, SMS OTP, Email OTP). A biometric visual fast-pass is **DEFERRED** until native `local_auth` integration is formally requested.

### 2.2 Live Workshop Floor Occupancy Heatmap
- **Proposed Feature:** Interactive 16-bay visual grid with real-time bay occupancy.
- **Repository Audit:** `SupervisorDashboardView` and `supervisor_bay_view` receive real `JobCardEntity` lists containing `bayId`, `status`, and assigned technician.
- **Classification:** **Tier 3 (Visual-Only Presentation Possible with Current Data)**.
- **Production UI Resolution:** Group the existing job cards by `bayId` to render the interactive floor grid without changing backend DTO schemas.

### 2.3 Live Revenue Velocity Curves & Sparklines
- **Proposed Feature:** Dynamic curves comparing today's billed revenue against target overhead.
- **Repository Audit:** `owner_app` has `dashboard_providers.dart` exposing daily revenue, pending approvals, and accounts receivable totals. Historical intra-day hourly telemetry is not returned by the API.
- **Classification:** **Tier 3 (Visual-Only Presentation Supported by Existing Data)**.
- **Production UI Resolution:** Render lightweight custom-painted sparklines representing multi-day revenue trends using existing historical data points. Do not mock fake intra-day hourly telemetry.

### 2.4 Interactive Spatial Damage Map (Pin-Drop Damage Hotspots)
- **Proposed Feature:** Tapping vehicle blueprint drops colored pins with severity (Dent, Scratch, Crack).
- **Repository Audit:** `inspection_sheet_view.dart` and `InspectionEntity` already support damage coordinate lists `List<DamagePoint>` with `x, y, type, notes`.
- **Classification:** **Tier 1 (Existing & Fully Supported)**.
- **Production UI Resolution:** Build the full Concept A `SpatialDamageHud` directly wired to existing `InspectionNotifier` state.

### 2.5 Real-Time Parts Inventory Stock Indicators
- **Proposed Feature:** Estimate builder displaying "In Stock • Bay 4" vs "Order from Supplier".
- **Repository Audit:** `staff_app` features `repair_order_view.dart` and `inventory_view.dart` with part search, part numbers, unit prices, and quantity on hand. Shelf/bay location strings exist only in some branches.
- **Classification:** **Tier 2 (Existing but Partially Supported)**.
- **Production UI Resolution:** Display stock count and availability status ("In Stock" / "Low Stock" / "Backorder"). Show bay locations only when populated in the DTO.

### 2.6 Customer Vehicle Health Score Index (e.g. "96% Health")
- **Proposed Feature:** Circular score pill on Customer Digital Garage.
- **Repository Audit:** The backend stores inspection items with Pass/Caution/Fail status. It does not calculate a single proprietary numeric percentage on the server.
- **Classification:** **Tier 3 (Visual-Only Presentation Supported by Client Math)**.
- **Production UI Resolution:** Compute the health score deterministically on the client: `(Passed Items / Total Checkpoints) * 100`. If no recent inspection exists, render "Pending Inspection" instead of an invented score.

### 2.7 Live Service Telemetry Progression Ribbon
- **Proposed Feature:** Real-time workshop stage progress (Intake -> Inspection -> Parts -> Labor -> QC -> Ready).
- **Repository Audit:** `customer_app` has `CustomerServiceStatusPage` wired to `activeJobStatusProvider` which resolves exact backend enums (`JobCardStatus.intake`, `inspection`, `estimateApproval`, `inProgress`, `qc`, `readyForDelivery`).
- **Classification:** **Tier 1 (Existing & Fully Supported)**.
- **Production UI Resolution:** Wire the 6-stage telemetry ribbon directly to the live `JobCardStatus` state notifier.

### 2.8 Drag-and-Drop Kanban Persistence (CRM & Advisor)
- **Proposed Feature:** Dragging lead cards between Kanban columns to trigger backend stage transition.
- **Repository Audit:** `crm_app` features `crm_lead_provider.dart` with `updateLeadStatus(leadId, newStatus)`. `staff_app` features `jobCardsProvider.updateStatus()`.
- **Classification:** **Tier 1 (Existing & Fully Supported)**.
- **Production UI Resolution:** Standard Flutter `DragTarget` / `Draggable` widgets will invoke existing provider mutation methods upon drop.

### 2.9 Financial Exports (FTA VAT Return PDF / Excel)
- **Proposed Feature:** One-tap export of formal tax audit summaries.
- **Repository Audit:** No native PDF/Excel generation libraries are declared in `owner_app/pubspec.yaml`.
- **Classification:** **Tier 4 (Requires New Dependencies)**.
- **Production UI Resolution:** Build the high-density on-screen financial data tables with clean print/copy actions. File exports are deferred until dedicated document generation packages are integrated.
