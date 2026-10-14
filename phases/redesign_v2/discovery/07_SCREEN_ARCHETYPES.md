# 07 — Dedicated Screen Archetypes & Composition Grammar

**Document ID:** `phases/redesign_v2/discovery/07_SCREEN_ARCHETYPES.md`  
**Status:** DRAFT / PENDING PRODUCT OWNER REVIEW (Stage A Discovery)  
**Author:** Principal Product Designer, Systems Architect & Lead Flutter Engineer  

---

## 1. The Core Philosophy: Purpose-Built Composition

A consistent, professional product **is NOT a product where every screen uses identical cards and arrangements**.

The previous redesign phases fell into visual monotony because every screen attempted to cram diverse workflows into a single generic layout template: `Header -> KPI Grid -> Card List -> Bottom Bar`.

In Redesign v2, we establish **11 Dedicated Screen Archetypes**. Each archetype features an intentional, purpose-built structural composition engineered specifically for its cognitive load, physical environment, and user journey—while sharing a unified typographic scale, color tokens, and design language.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        SCREEN ARCHETYPE MATRIX                         │
├──────────────────────────┬──────────────────────────┬──────────────────┤
│ Consumer & Growth Flows  │ Operational & Shop Floor │ Executive & BI   │
├──────────────────────────┼──────────────────────────┼──────────────────┤
│ 1. High-Trust Auth       │ 4. Tactical Advisor Hub  │ 8. Executive BI  │
│ 2. Customer Garage/Home  │ 5. Visual Intake Studio  │ 9. Analytical    │
│ 3. Guided Booking Flow   │ 6. Inspection Canvas HUD │ 10. CRM Pipeline │
│                          │ 7. Hands-On Tech Station │ 11. System Prefs │
└──────────────────────────┴──────────────────────────┴──────────────────┘
```

---

## 2. Comprehensive Archetype Specifications

### Archetype 1: Brand-Led High-Trust Authentication
- **Target Screens**: `LoginView`, `ForgotPasswordView`, `SupervisorLoginView`, `AuthLoadingView`.
- **Purpose**: Welcoming, secure, frictionless identity verification with zero clutter.
- **Structural Composition**:
  - **Mobile (<600px)**: 100vh immersive canvas; subtle ambient vehicle lighting at top; brand mark + contextual greeting; focused input container with floating label; prominent biometrics/OTP toggle; persistent security badge.
  - **Desktop (≥1024px)**: Asymmetric 45/55 split; left panel features high-contrast brand imagery, security certifications, and live cluster status; right panel features an uncluttered, keyboard-focused authentication form.
- **Key Interactions**: Auto-detects identifier type (UAE phone vs email); auto-advancing 6-digit OTP code inputs; smooth error shake animation; instant biometric prompt.

---

### Archetype 2: Consumer Digital Garage & Concierge (Customer Home)
- **Target Screens**: `CustomerDashboardView` (Home Tab), `CustomerVehiclesTab`.
- **Purpose**: Pride of vehicle ownership, instant status visibility, and effortless service scheduling.
- **Structural Composition**:
  - **Hero Zone**: High-resolution vehicle silhouette showcase with live health score arc ("96% Health • Next Service in 2,400 KM").
  - **Live Service Ribbon**: If an active workshop job exists, an animated progress ribbon floats contextually beneath the vehicle with stage ticker ("Active: Wheel Alignment • 35 mins remaining").
  - **Action Dock**: 4 quick concierge triggers (Book Service, Roadside SOS, Vehicle Docs, Contact Advisor).
  - **Recent Activity Feed**: Compact, horizontal swipe cards of past invoices and maintenance milestones.
- **Key Interactions**: Swiping horizontally between customer vehicles smoothly updates the health score, service history, and background lighting.

---

### Archetype 3: Multi-Step Guided Service Booking (Wizard Flow)
- **Target Screens**: `CustomerBookServiceView`, `AddVehicleView`, `CustomerFeedbackView`.
- **Purpose**: Confidence-building, zero-friction booking and data entry with transparent pricing.
- **Structural Composition**:
  - **Sticky Progress Header**: Minimalist step indicator showing current stage, estimated time to complete, and quick-back button.
  - **Focused Card Deck**: Center canvas presenting only the active step (e.g. Service Package Selection) with clear visual options, pricing tags, and included service lists.
  - **Floating Summary Ribbon**: Displays running cost total, selected date/time slot, and a prominent "Continue" button.
- **Key Interactions**: Micro-animations on card selection; calendar slot picker with real-time bay availability pills; celebratory completion badge.

---

### Archetype 4: Tactical Advisor Operational Hub
- **Target Screens**: `AdvisorHomeView`, `AdvisorJobsView`, `SupervisorDashboardView`.
- **Purpose**: Rapid shop-floor triage, bottleneck identification, and instant customer dispatch.
- **Structural Composition**:
  - **Workshop Throughput Radar**: Horizontal scrolling KPI ticker showing live vehicle counts categorized by urgency: Intake (4), Inspection (2), Estimate Pending (5), In Repair (8), QC/Delivery (3).
  - **Filter Ribbon**: Sticky, horizontal pill bar with search input and one-tap stage filters with live count badges.
  - **Job Card Matrix**: High-density cards featuring vehicle plate badge, customer name, assigned technician avatar, elapsed time timer, and action button.
- **Key Interactions**: Swiping a job card reveals quick actions (Call Customer, Assign Bay, View Estimate); long-press enables bulk dispatch mode.

---

### Archetype 5: Visual Vehicle Intake Studio
- **Target Screens**: `VehicleCustomerView`, `ScanVehicleView`, `AdvisorVehicleCheckinView`.
- **Purpose**: Accurate, rapid physical capture of customer, vehicle, and intake condition.
- **Structural Composition**:
  - **Top Step Navigator**: Visual intake stages (Customer ID -> Vehicle Specs -> Initial Walkaround -> Signature).
  - **Dual Input Pane (Tablet/Desktop)**: Left pane hosts camera scanner / OCR plate preview; right pane auto-populates parsed customer data.
  - **Digital Instrument Cluster**: Tactile fuel level gauge (slider with fuel pump icon) and rolling drum odometer input.
- **Key Interactions**: Camera scanner auto-detects VIN barcode and fetches manufacturer model specs in real time; digital signature pad with stroke smoothing.

---

### Archetype 6: Spatial Inspection Canvas & HUD
- **Target Screens**: `InspectionSheetView`, `ChooseInspectionView`, `InspectionPreviewView`.
- **Purpose**: Precise, visual vehicle condition recording and damage documentation.
- **Structural Composition**:
  - **Vehicle Canvas**: Centered vector/3D vehicle outline with interactive body panels (Front Bumper, Hood, Windshield, Doors, Quarter Panels).
  - **Checkpoint Rail (Desktop/Tablet)**: Pinned left rail with checkpoint categories (Engine, Brakes, Suspension, Interior, Electrical).
  - **Tappable Damage Pinpoint**: Dropping a pin on a panel opens a micro-inspector to select damage type (Scratch, Dent, Crack, Rust) and attach photos/audio.
  - **Tactile Toggle Triggers**: Large three-state toggle rings for Pass (Green), Caution (Amber), and Fail (Red).
- **Key Interactions**: Direct touch canvas interaction; voice note recording with live waveform visualizer; camera thumbnail tray with photo count badges.

---

### Archetype 7: Distraction-Free Hands-On Station (Technician)
- **Target Screens**: `TechnicianDashboardView`, `TechnicianTodayView`, `JobDetailSheet`.
- **Purpose**: Ergonomic, glove-friendly repair execution and parts tracking under shop-floor conditions.
- **Structural Composition**:
  - **High-Contrast Shift Banner**: Pinned top bar showing active clock-in time and active bay number.
  - **Dominant Active Job Card**: Occupies 60% of mobile viewport; displays vehicle plate, primary repair instruction, and large elapsed timer.
  - **Oversized Action Triggers**: Minimum 64px button height for Start Task, Hold Task, and Request Parts.
  - **Parts Requisition Drawer**: Slide-over drawer with instant barcode scanning for replacement parts.
- **Key Interactions**: Tactile slide-to-confirm for starting/completing critical repair operations to prevent accidental screen taps from greasy gloves.

---

### Archetype 8: Executive Cockpit & Financial Intelligence (Owner)
- **Target Screens**: `OwnerDashboardView`, `JobCardsListView`, `PendingApprovalsView`.
- **Purpose**: High-level business oversight, revenue velocity, cash flow, and executive decision-making.
- **Structural Composition**:
  - **Financial Telemetry Ticker**: Real-time revenue rate, gross margin %, average repair order value (RO), and floor utilization.
  - **Interactive Analytics Grid**: Side-by-side revenue trend sparklines and labor vs parts margin waterfall charts.
  - **Executive Work Register**: Dense, sortable data table with frozen vehicle columns, live status indicators, and one-tap invoice drill-down.
- **Key Interactions**: Date range picker (Today, WTD, MTD, QTD, Custom) with instant non-reloading data refresh; hover tooltips on chart data points.

---

### Archetype 9: Dense Analytical & Audit Workspace (Reports & Compliance)
- **Target Screens**: `AdvisorReportsView`, `SupervisorReportsTab`, `AccountsReceivableView`, `DocumentExpiryView`.
- **Purpose**: Deep analytical inquiry, debt aging tracking, and regulatory audit compliance.
- **Structural Composition**:
  - **Control & Filter Toolbar**: Pinned multi-filter bar with date selector, department dropdown, and export triggers (PDF, Excel).
  - **Macro Summary Cards**: 3 compact stat pods showing Total Aging Debt, Average Days Sales Outstanding (DSO), and Overdue Invoices.
  - **Ledger Table**: Full-width data table with zebra striping, sticky headers, and color-coded aging buckets (Current, 30 Days, 60 Days, 90+ Days).
- **Key Interactions**: Clicking any debt row slides open a customer communication drawer with WhatsApp payment reminder shortcuts.

---

### Archetype 10: Multi-View Pipeline & Customer Hub (CRM)
- **Target Screens**: `CrmDashboardView`, `CrmLeadsPage`, `CrmConversationsPage`.
- **Purpose**: Omnichannel lead acquisition, sales pipeline management, and customer messaging.
- **Structural Composition**:
  - **Pipeline / Kanban Board**: Drag-and-drop stage columns (New Inquiries -> Contacted -> Qualified -> Proposal Sent -> Won / Lost).
  - **Master-Detail Split View**: On tablet/desktop, conversation threads on left, live active chat in center, and 360-degree customer profile on right.
  - **Quick Action Launcher**: Bottom floating dock for creating a new lead, sending broadcast SMS, or scheduling a follow-up.
- **Key Interactions**: Drag-and-drop lead stage transitions; typing `/quote` in conversation drawer opens estimate builder snippet.

---

### Archetype 11: Structured System & Account Preferences
- **Target Screens**: `SettingsPage`, `StaffProfileScreen`, `CustomerProfileTab`, `SubscriptionView`.
- **Purpose**: Discoverable, grouped preferences, security settings, and account governance.
- **Structural Composition**:
  - **Account Header**: Clean identity card with profile avatar, role badge, and membership tier.
  - **Segmented Preference Sections**: Grouped settings tiles with clear visual iconography, descriptive subtext, and native toggle switches.
  - **System Telemetry Footer**: App version, offline database sync status, and haptic logout button.
- **Key Interactions**: Instant locale toggle (English <-> Arabic) with smooth layout mirroring animation; biometric authentication toggle with FaceID confirmation.
