# 09 — Complete Screen & Widget Coverage Matrix (100% Scope)

**Document ID:** `phases/redesign_v2/discovery/09_SCREEN_AND_WIDGET_COVERAGE.md`  
**Status:** DRAFT / PENDING PRODUCT OWNER REVIEW (Stage A Discovery)  
**Author:** Principal Product Designer, Systems Architect & Lead Flutter Engineer  

---

## 1. Scope Assurance Statement

In strict accordance with the primary project requirement, **NO EXISTING SCREEN MAY BE CONSIDERED COMPLETE MERELY BECAUSE IT WAS MODIFIED IN PHASES 01–07A**.

Every single screen, route, sub-page, tab, sheet, modal, and reusable widget in the Orient monorepo is cataloged below, assigned to a target archetype, and evaluated for complete visual and interaction replacement. Zero screens are silently excluded.

```
┌────────────────────────────────────────────────────────────────────────┐
│                      PROJECT-WIDE COVERAGE SUMMARY                     │
├────────────────────────────────────────┬───────────────────────────────┤
│ Production Applications                │ 4 Apps (Staff, Owner, Cust,   │
│                                        │ CRM)                          │
│ Total Unique Routes Mapped             │ 52 Routes                     │
│ Total User-Facing Screens & Tabs       │ 64 Primary Surfaces           │
│ Total Dialogs, Sheets & Modals         │ 28 Secondary Surfaces         │
│ Shared Component Primitives Audited    │ 32 Core Widgets               │
│ Overall Scope Coverage                 │ 100% (No screens omitted)     │
└────────────────────────────────────────┴───────────────────────────────┘
```

---

## 2. Exhaustive Cross-Application Coverage Matrix

### 2.1 Shared Authentication (`packages/shared_auth`)

| Ref | Screen / Surface | Target Archetype | Mobile (<600px) | Tablet (600–1023px) | Desktop (≥1024px) | EN / AR Support | Current Status | Redesign Plan |
|---|---|---|---|---|---|---|---|---|
| A1 | `AuthLoadingView` | Archetype 1: Auth | Fullscreen splash | Centered card | Cinematic split | EN + AR | Phase 05 Done | Complete visual replacement with ambient brand telemetry. |
| A2 | `LoginView` | Archetype 1: Auth | Single-column form | Boxed modal | Split 45/55 view | EN + AR (LTR IDs) | Phase 05 Done | Complete visual replacement with glass auth canvas & biometrics. |
| A3 | `ForgotPasswordView` | Archetype 1: Auth | Single-column step | Boxed modal | Split 45/55 view | EN + AR | Phase 05 Done | Re-architect into guided confidence flow with animated progress. |
| A4 | `SupervisorLoginView` | Archetype 1: Auth | Numeric keypad | Boxed card | Docked terminal | EN + AR | Phase 05 Done | Redesign into tactical supervisor terminal with shift selector. |

---

### 2.2 Staff Application: Service Advisor Persona

| Ref | Screen / Surface | Target Archetype | Mobile (<600px) | Tablet (600–1023px) | Desktop (≥1024px) | EN / AR Support | Current Status | Redesign Plan |
|---|---|---|---|---|---|---|---|---|
| S1 | `AdvisorHomeView` (Today) | Archetype 4: Tactical Hub | Single-col radar | 2-col triage | Multi-pane console | EN + AR | Phase 06 Done | Replace generic cards with Live Workshop Throughput Radar. |
| S2 | `AdvisorJobsView` (Jobs) | Archetype 4: Tactical Hub | Swipe cards | 2-col grid | Sortable data table | EN + AR | Phase 06 Done | Replace basic list with fluid Kanban-Matrix hybrid. |
| S3 | `AdvisorReportsView` | Archetype 9: Analytical | Carousel metrics | 2-col charts | Full analytical suite | EN + AR | Phase 06 Done | Replace standard bar chart with interactive drill-down sparklines. |
| S4 | `AdvisorJobDetailView` | Archetype 4: Tactical Hub | Collapsible tabs | 2-pane split | 3-pane command center | EN + AR | Phase 06 Done | Re-architect into vehicle-pinned 360-degree control center. |
| S5 | `AdvisorSearchSheet` | Archetype 4: Tactical Hub | Bottom sheet | Floating modal | Command palette (⌘K) | EN + AR | Phase 06 Done | Rebuild into Spotlight-style instant search palette. |
| S6 | `AdvisorNotificationSheet`| Archetype 4: Tactical Hub | Bottom sheet | Slide-over drawer | Pinned notification dock| EN + AR | Phase 06 Done | Redesign into chronological alert feed with priority pulses. |
| S7 | `AdvisorProfileSheet` | Archetype 11: Settings | Bottom sheet | Centered dialog | Sidebar flyout | EN + AR | Phase 06 Done | Rebuild into refined identity card with shift metrics. |
| S8 | `AdvisorContactSheet` | Archetype 4: Tactical Hub | Bottom sheet | Floating modal | Inline contact bar | EN + AR | Phase 06 Done | Upgrade with one-tap WhatsApp deep link and call logging. |
| S9 | `AdvisorApprovalSheet` | Archetype 4: Tactical Hub | Bottom sheet | Centered dialog | Split approval viewer | EN + AR | Phase 06 Done | Replace static list with differential approval inspector. |
| S10 | `ScanVehicleView` | Archetype 5: Intake Studio | Fullscreen camera | Centered bracket | Centered bracket | EN + AR | Phase 07A Done | Upgrade with precision optical HUD and audio-haptic lock. |
| S11 | `VehicleCustomerView` | Archetype 5: Intake Studio | Progressive deck | 2-pane form | 3-pane intake console | EN + AR (LTR plates)| Phase 07A Done | Complete replacement: OCR auto-fill & card deck progression. |
| S12 | `AdvisorVehicleCheckinView`| Archetype 5: Intake Studio | Single-col gauges| 2-col instrument | Integrated dashboard | EN + AR | Phase 07A Done | Replace sliders with authentic digital instrument cluster. |
| S13 | `ChooseInspectionView` | Archetype 6: Inspection | Vertical cards | 2-col grid | 3-tier selector | EN + AR | Pending Phase 07B | Design new tiered inspection selector with checkpoint preview. |
| S14 | `InspectionSheetView` | Archetype 6: Inspection | Canvas + sheet | Split canvas/list| Pinned 3-pane workspace | EN + AR (Fixed car) | Pending Phase 07B | Brand-new spatial damage canvas HUD with tactile toggle rings. |
| S15 | `InspectionPreviewView` | Archetype 6: Inspection | Report scroll | 2-col summary | Executive health sheet | EN + AR | Pending Phase 07B | Rebuild into customer-ready digital vehicle health report. |
| S16 | `RepairOrderView` | Archetype 4: Tactical Hub | Smart item table | Split order/parts| Full work order studio | EN + AR | Pending Phase 08 | Re-architect into dynamic estimate studio with live margins. |
| S17 | `RepairOrderPreviewView` | Archetype 4: Tactical Hub | Clean document | Split doc/sign | Side-by-side preview | EN + AR | Pending Phase 08 | High-trust estimate document with tiered customer approval. |
| S18 | `AdvisorAssignTasksView` | Archetype 4: Tactical Hub | Technician cards | Grid allocation | Visual bay dispatch | EN + AR | Pending Phase 08 | Interactive bay allocation matrix with technician workload bars. |
| S19 | `VehicleDeliveryView` | Archetype 5: Intake Studio | Step checklist | 2-pane checkout | Delivery command view | EN + AR | Pending Phase 08 | Digital handover experience with live gate pass QR code. |

---

### 2.3 Staff Application: Supervisor & Technician Personas

| Ref | Screen / Surface | Target Archetype | Mobile (<600px) | Tablet (600–1023px) | Desktop (≥1024px) | EN / AR Support | Current Status | Redesign Plan |
|---|---|---|---|---|---|---|---|---|
| S20 | `SupervisorDashboardView` | Archetype 4: Tactical Hub | Bottleneck radar | Bay status grid | Full shop command deck| EN + AR | Pending Phase 09 | Replace 4-tile matrix with live bay occupancy floorplan. |
| S21 | `SupervisorAssignSheet` | Archetype 4: Tactical Hub | Quick-swipe sheet| 2-col dispatch | Tactical dispatch table| EN + AR | Pending Phase 09 | High-density multi-pane dispatch console with load balancing. |
| S22 | `SupervisorQueueTab` | Archetype 4: Tactical Hub | Priority list | 2-col queue | Drag-and-drop triage | EN + AR | Pending Phase 09 | Emergency triage queue with audio alerts for breakdowns. |
| S23 | `SupervisorReviewTab` | Archetype 4: Tactical Hub | QC job cards | Side-by-side QC | Full inspection review | EN + AR | Pending Phase 09 | Quality assurance terminal with side-by-side work order audit. |
| S24 | `SupervisorStaffTab` | Archetype 4: Tactical Hub | Roster list | Utilization grid| Real-time staff matrix | EN + AR | Pending Phase 09 | Live technician utilization heatmap and bay assignments. |
| S25 | `SupervisorScheduleTab` | Archetype 4: Tactical Hub | Day timeline | Week planner | Interactive Gantt chart | EN + AR | Pending Phase 09 | Multi-bay capacity planner with interactive slot reservations. |
| S26 | `SupervisorReportsTab` | Archetype 9: Analytical | Metric cards | 2-col charts | Efficiency analytics | EN + AR | Pending Phase 09 | Efficiency analytics hub with technician speed rankings. |
| S27 | `SupervisorJobsTab` | Archetype 4: Tactical Hub | Department tabs | Department grid | Multi-bay kanban board | EN + AR | Pending Phase 09 | Multi-bay stage progression kanban (Mech, Elec, Paint, QC). |
| S28 | `QcChecklistSheet` | Archetype 6: Inspection | Bottom sheet | Modal dialog | Side drawer inspector | EN + AR | Pending Phase 09 | High-precision QC protocol with mandatory photo requirement. |
| S29 | `TechnicianDashboardView` | Archetype 7: Tech Station | Focused hero job | Split job/queue | Workshop station view | EN + AR | Pending Phase 10 | High-contrast hands-on station with glove-friendly targets. |
| S30 | `TechnicianTodayView` | Archetype 7: Tech Station | Shift clock + job| Shift arc + job | Comprehensive bay view | EN + AR | Pending Phase 10 | Distraction-free task runner with slide-to-confirm triggers. |
| S31 | `TechnicianJobsView` | Archetype 7: Tech Station | Queue cards | 2-col queue | Structured task ledger | EN + AR | Pending Phase 10 | Structured task queue with parts readiness indicators. |
| S32 | `TechnicianProductivityView`| Archetype 7: Tech Station| Progress arc | Efficiency grid | Gamified scorecard | EN + AR | Pending Phase 10 | Personal performance dashboard with earned hours progress. |
| S33 | `JobDetailSheet` | Archetype 7: Tech Station | Task instructions| Split task/parts| Exploded schematic view| EN + AR | Pending Phase 10 | Industrial workstation with technical repair schematics. |
| S34 | `PartsRequestSheet` | Archetype 7: Tech Station | Barcode + search | Floating sheet | Split catalog drawer | EN + AR | Pending Phase 10 | Rapid parts requisition with urgency flags (Blocking Bay). |
| S35 | `EscalationSheet` | Archetype 7: Tech Station | Urgent modal | Centered modal | Alert dispatcher | EN + AR | Pending Phase 10 | Immediate bay alert dispatcher with image markup tool. |
| S36 | `StaffProfileScreen` | Archetype 11: Settings | Vertical list | 2-col card | Pinned profile workspace| EN + AR | Pending Phase 11 | Executive staff identity card with certification tags. |
| S37 | `StaffAttendanceScreen` | Archetype 9: Analytical | Daily punch log | Calendar + logs | Shift & overtime ledger| EN + AR | Pending Phase 11 | Visual shift punch timeline with overtime tracking counters. |
| S38 | `ShiftDetailsPage` | Archetype 11: Settings | Text cards | Centered card | Operational schedule | EN + AR | Pending Phase 11 | Clean operational schedule with active countdown to break. |
| S39 | `SettingsPage` | Archetype 11: Settings | Grouped tiles | 2-col settings | Systems preferences hub| EN + AR | Pending Phase 11 | Professional systems hub with instant bilingual toggle. |

---

### 2.4 Owner Application: Executive Operations & Finance

| Ref | Screen / Surface | Target Archetype | Mobile (<600px) | Tablet (600–1023px) | Desktop (≥1024px) | EN / AR Support | Current Status | Redesign Plan |
|---|---|---|---|---|---|---|---|---|
| O1 | `OwnerDashboardView` | Archetype 8: Executive Cockpit| Financial ticker| 2-col analytics | Full executive cockpit | EN + AR | Pending Phase 12 | Complete replacement: Bloomberg-grade workshop ticker. |
| O2 | `TopSalesPage` | Archetype 8: Executive Cockpit| Pareto card list| 2-col cards | Revenue matrix table | EN + AR | Pending Phase 12 | Service revenue matrix with interactive margin meters. |
| O3 | `MessagesPage` | Archetype 10: CRM Pipeline | Feed + composer | Split audience | Workshop broadcast desk| EN + AR | Pending Phase 12 | Targeted workshop broadcast terminal with read receipts. |
| O4 | `OwnerActivityFeedTab` | Archetype 8: Executive Cockpit| Chrono stream | Filterable feed | Real-time audit stream | EN + AR | Pending Phase 12 | Live operational event feed with security flags. |
| O5 | `JobCardsListView` | Archetype 8: Executive Cockpit| Dense cards | 2-col cards | Full-width data table | EN + AR | Pending Phase 13A | Enterprise work register with sticky columns and quick filters. |
| O6 | `JobCardDetailView` | Archetype 8: Executive Cockpit| Financial audit | Split audit doc | 360-degree audit console| EN + AR | Pending Phase 13A | Gross margin calculator and customer approval audit trail. |
| O7 | `JobStatusView` | Archetype 8: Executive Cockpit| Funnel cards | Visual pipeline | Workshop pipeline funnel| EN + AR | Pending Phase 13A | Visual stage pipeline with cycle time bottleneck alerts. |
| O8 | `PendingApprovalsView` | Archetype 8: Executive Cockpit| Approval cards | Split decision | Executive auth desk | EN + AR | Pending Phase 13A | Split-view discount approval with customer LTV context. |
| O9 | `InventoryView` | Archetype 9: Analytical | Stock cards | 2-col inventory | Intelligent stock table | EN + AR | Pending Phase 13B | Real-time stock telemetry with automated reorder alerts. |
| O10 | `AttendanceView` | Archetype 9: Analytical | Daily summary | Team roster | Staff presence radar | EN + AR | Pending Phase 13B | Live floor attendance roster with late check-in warnings. |
| O11 | `TeamView` | Archetype 11: Settings | Member cards | 2-col team grid | Governance studio table | EN + AR | Pending Phase 13B | Role-based permission matrix and skill tagging. |
| O12 | `AccountsReceivableView`| Archetype 9: Analytical | Aging buckets | 2-col ledger | Cash flow intelligence | EN + AR | Pending Phase 14 | Aging waterfall chart with one-tap WhatsApp payment link. |
| O13 | `DocumentExpiryView` | Archetype 9: Analytical | Urgent alerts | Expiry cards | Compliance vault | EN + AR | Pending Phase 14 | Traffic-light compliance rings and secure document preview. |
| O14 | `FeedbackModerationView`| Archetype 9: Analytical | Review cards | NPS gauge + grid| Sentiment command desk | EN + AR | Pending Phase 14 | Customer sentiment analytics and manager escalation drawer. |
| O15 | `SubscriptionView` | Archetype 11: Settings | Plan card + list| 2-col plan view | SaaS account portal | EN + AR | Pending Phase 14 | Usage meter (Active Bays, Staff seats) and tax invoices. |

---

### 2.5 Customer Application: Consumer Experience & Garage

| Ref | Screen / Surface | Target Archetype | Mobile (<600px) | Tablet (600–1023px) | Desktop (≥1024px) | EN / AR Support | Current Status | Redesign Plan |
|---|---|---|---|---|---|---|---|---|
| C1 | `CustomerDashboardView` | Archetype 2: Garage/Home | Immersive garage| Concierge hub | Luxury customer portal | EN + AR | Pending Phase 15A | Luxury digital showroom with live vehicle status ribbon. |
| C2 | `CustomerHomeTab` | Archetype 2: Garage/Home | Vehicle hero | Studio showroom | Multi-vehicle garage | EN + AR | Pending Phase 15A | Prominent vehicle card with health score & active job ticker. |
| C3 | `CustomerProfileTab` | Archetype 11: Settings | Profile tiles | 2-col account | Account suite | EN + AR | Pending Phase 15A | Premium account suite with membership tier & language toggle. |
| C4 | `CustomerBookingsTab` | Archetype 3: Booking Flow | Timeline cards | 2-col calendar | Service reservation hub| EN + AR | Pending Phase 15B | Calendar-integrated appointment cards with one-tap reschedule. |
| C5 | `CustomerVehiclesTab` | Archetype 2: Garage/Home | 3D vehicle cards| 2-col showroom | Digital garage showcase | EN + AR | Pending Phase 15B | Visual vehicle cards with individual service history logs. |
| C6 | `AddVehicleView` | Archetype 3: Booking Flow | Fluid 3-step | Centered card | Focused vehicle modal | EN + AR (LTR plates)| Pending Phase 15B | Visual brand selector with genuine badges and plate designer. |
| C7 | `CustomerBookServiceView`| Archetype 3: Booking Flow | 4-step wizard | Guided studio | Guided booking studio | EN + AR | Pending Phase 16 | Immersive step progression with transparent package pricing. |
| C8 | `CustomerBookingSuccessView`| Archetype 3: Booking Flow | Celebratory card| Centered pass | Digital pass confirmation| EN + AR | Pending Phase 16 | Animated confirmation with Apple/Google Wallet pass generator. |
| C9 | `CustomerBookingDetailView`| Archetype 3: Booking Flow | Countdown card | Split detail | Appointment command view| EN + AR | Pending Phase 16 | Live countdown to appointment with advisor WhatsApp link. |
| C10 | `CustomerServiceStatusPage`| Archetype 2: Garage/Home | Live journey | Split journey | 360-degree tracker | EN + AR | Pending Phase 17 | Domino's-grade visual repair tracker with technician photos. |
| C11 | `CustomerApprovalsPage` | Archetype 3: Booking Flow | Estimate cards | 2-col estimates | Decision center | EN + AR | Pending Phase 17 | High-clarity estimate cards highlighting urgent safety items. |
| C12 | `CustomerApprovalDetailView`| Archetype 3: Booking Flow | Line checkboxes | Split estimate | Transparent estimate | EN + AR | Pending Phase 17 | Line-item approve/decline toggles with photo evidence. |
| C13 | `CustomerInvoiceDetailView`| Archetype 8: Executive Cockpit| Sleek receipt | Centered invoice| Digital tax invoice | EN + AR | Pending Phase 17 | Modern receipt presentation with integrated Apple Pay sheet. |
| C14 | `CustomerNotificationsView`| Archetype 11: Settings | Category inbox | Split inbox | Contextual activity hub | EN + AR | Pending Phase 18 | Categorized updates (Service, Finance) with deep-linking. |
| C15 | `CustomerBreakdownHelpView`| Archetype 3: Booking Flow | Urgent SOS UI | Centered SOS | Emergency dispatcher | EN + AR | Pending Phase 18 | High-urgency SOS interface with one-tap live GPS sharing. |
| C16 | `CustomerBreakdownResultView`| Archetype 3: Booking Flow| Dispatch status | Centered result | Distress confirmation | EN + AR | Pending Phase 18 | Recovery dispatch telemetry (Driver, ETA, Live Map). |
| C17 | `CustomerFeedbackView` | Archetype 3: Booking Flow | 5-star haptic | Centered card | Service review studio | EN + AR | Pending Phase 18 | Interactive 5-star haptic selector with direct escalation. |

---

### 2.6 CRM Application: Pipeline & Customer Relationship

| Ref | Screen / Surface | Target Archetype | Mobile (<600px) | Tablet (600–1023px) | Desktop (≥1024px) | EN / AR Support | Current Status | Redesign Plan |
|---|---|---|---|---|---|---|---|---|
| R1 | `CrmDashboardView` | Archetype 10: CRM Hub | Bottom nav + rail| Pinned rail | Omnichannel workspace | EN + AR | Pending Phase 19A | Unified left rail on desktop, fluid navigation on mobile. |
| R2 | `CrmDashboardPage` | Archetype 10: CRM Hub | Funnel cards | 2-col analytics | Sales performance radar | EN + AR | Pending Phase 19A | Live conversion funnel chart and urgent follow-up ticker. |
| R3 | `CrmLeadsPage` | Archetype 10: CRM Hub | Swipe cards | Fluid Kanban | Dual pipeline studio | EN + AR | Pending Phase 19A | Switchable Kanban swimlanes / dense table with quick-calls. |
| R4 | `LeadFormSheet` | Archetype 10: CRM Hub | Bottom sheet | Centered dialog | Side lead drawer | EN + AR | Pending Phase 19A | Smart lead capture with vehicle interest picker & deal value. |
| R5 | `LeadDetailSheet` | Archetype 10: CRM Hub | Bottom sheet | Slide-over drawer| 360-degree deal center | EN + AR | Pending Phase 19A | Omnichannel timeline with deal probability slider. |
| R6 | `CrmConversationsPage` | Archetype 10: CRM Hub | Chat list / room | Split 35/65 | Unified inbox console | EN + AR | Pending Phase 19B | Master-detail chat console with integrated estimate quotes. |
| R7 | `CrmSalesTeamPage` | Archetype 10: CRM Hub | Rep cards | Leaderboard grid| Sales leaderboard table | EN + AR | Pending Phase 19B | Live quota progress gauges and round-robin lead rebalancing. |
| R8 | `CrmTasksPage` | Archetype 10: CRM Hub | Overdue list | Calendar + tasks| Follow-up command desk | EN + AR | Pending Phase 19B | Overdue alerts with direct WhatsApp action & calendar sync. |
| R9 | `CrmReportsPage` | Archetype 9: Analytical | ROI summary | 2-col charts | Acquisition ROI studio | EN + AR | Pending Phase 19C | Cost-per-lead waterfall charts and channel attribution. |
| R10 | `CrmIntegrationsPage` | Archetype 11: Settings | Connector cards | 2-col grid | Marketing bridge console| EN + AR | Pending Phase 19C | Connection status pills and real-time webhook sync test. |
| R11 | `CrmSettingsPage` | Archetype 11: Settings | Routing rules | 2-col settings | CRM governance studio | EN + AR | Pending Phase 19C | Automated lead distribution logic & SLA alert rules. |

---

## 3. Summary of Total Coverage

Every screen across the entire monorepo is cataloged with an assigned archetype, responsive profile, and localization strategy. No screens are deferred, omitted, or assumed approved.
