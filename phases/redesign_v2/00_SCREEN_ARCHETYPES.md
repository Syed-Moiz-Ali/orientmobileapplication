# 00 — Dedicated Screen Archetypes Specification (Redesign v2)

**Document ID:** `phases/redesign_v2/00_SCREEN_ARCHETYPES.md`  
**Purpose:** Permanently prevent repetitive card syndrome and template monotony  
**Scope:** 11 Purpose-Built Structural Screen Archetypes  
**Status:** FROZEN ARCHETYPE SPECIFICATION  

---

## 1. Overview & Rationale

A primary reason the Phase 00–07A redesign failed was **template monotony**: virtually every screen followed the identical formula of an AppBar, an orange banner, 4 rectangular KPI cards, and a vertical list view.

In Concept A Redesign v2, every screen is assigned to one of **11 specialized screen archetypes**, each engineered around the distinct information architecture and interaction goals of its specific workflow.

---

## 2. The 11 Purpose-Built Archetypes

### Archetype 1: Authentication & Identity Access
- **Purpose:** High-trust, focused, distraction-free access.
- **Composition:** Centered security card (max width 420px), ambient security status badge (`TLS 1.3 SECURE`), toggleable role selector pills, biometric quick-tap button, and clean keypad/PIN inputs.
- **Assigned Screens:** `LoginView`, `ForgotPasswordView`, `SupervisorLoginView`, `AuthLoadingView`.

### Archetype 2: Consumer Digital Garage (Customer Home)
- **Purpose:** Vehicle-as-hero ownership portal.
- **Composition:** High-impact vehicle studio showcase card with license plate badge, real-time vehicle health score pill (`96% HEALTH`), live active service telemetry ribbon, and rapid one-tap service action buttons.
- **Assigned Screens:** `CustomerHomeView`, `VehicleListView`, `VehicleDetailView`.

### Archetype 3: Guided Confidence Flow (Service Booking)
- **Purpose:** Low-cognitive-load, multi-step consumer booking.
- **Composition:** Sticky step progress ring, large selectable visual service cards, interactive calendar slot selector, transport option pills (Valet vs Workshop Drop-off), and clean price summary dock.
- **Assigned Screens:** `BookingStep1VehicleView` through `BookingStep4ConfirmView`, `AddVehicleWizardView`.

### Archetype 4: Tactical Operations Radar (Advisor Command Center)
- **Purpose:** High-throughput daily workshop management.
- **Composition:** Workshop floor throughput status bar, urgent triage radar (vehicles waiting for estimate, approvals pending, parts arrived), swimlane job cards with live bay timers, and floating command search bar.
- **Assigned Screens:** `AdvisorHomeView`, `AdvisorJobsView`, `AdvisorJobDetailView`.

### Archetype 5: Express Vehicle Intake Studio
- **Purpose:** Fast, error-free customer & vehicle check-in.
- **Composition:** Split camera OCR view for VIN/plates, digital instrument cluster for fuel level and odometer drum scroller, rapid 360-degree damage check, and digital signature capture dock.
- **Assigned Screens:** `ScanVehicleView`, `VehicleCustomerView`, `AdvisorVehicleCheckinView`.

### Archetype 6: Spatial Inspection HUD (Evidence Workspace)
- **Purpose:** Hands-on vehicle checkpoint grading and physical damage capture.
- **Composition:** Prominent interactive 8-perspective vehicle damage map with tap-to-pin hotspots, tactile Pass/Caution/Fail toggle rings, audio note recorder, and photo attachment grid.
- **Assigned Screens:** `ChooseInspectionView`, `InspectionSheetView`, `InspectionPreviewView`.

### Archetype 7: Task Execution Bay (Technician Console)
- **Purpose:** Distraction-free, grease-friendly workshop execution.
- **Composition:** Large high-contrast job header, active task stopwatch with pause/resume, high-touch checkbox items, one-tap parts requisition sheet, and QC handover button.
- **Assigned Screens:** `TechnicianHomeView`, `TechnicianJobDetailView`, `TechnicianClockView`, `TechnicianQcView`.

### Archetype 8: Executive Cockpit & Financial Desk (Owner)
- **Purpose:** Strategic business intelligence and financial decision-making.
- **Composition:** Live revenue velocity ticker (`AED 48,250.00`), interactive revenue vs target curves, floor occupancy bay heatmap, gross margin sparklines, and pending high-value approval cards.
- **Assigned Screens:** `OwnerDashboardView`, `WorkshopOperationsView`, `FinancialAnalyticsView`, `JobManagementView`.

### Archetype 9: Deal Radar & Conversion Pipeline (CRM)
- **Purpose:** Sales velocity, relationship management, and lead tracking.
- **Composition:** Lead Radar summary pods, visual drag-and-drop Kanban swimlanes (New -> Contacted -> Estimate Sent -> Won), lead value tags, probability percentages, and quick WhatsApp action buttons.
- **Assigned Screens:** `CrmDashboardView`, `LeadPipelineView`, `LeadListView`, `LeadDetailView`.

### Archetype 10: Omnichannel Conversation Console (CRM / Comms)
- **Purpose:** Unified messaging across WhatsApp, SMS, and email.
- **Composition:** 2-pane / 3-pane split view (Active contact list on left, real-time message thread in center, customer vehicle dossier on right) with template insertion chips and estimate attachment link.
- **Assigned Screens:** `ConversationsHubView`, `ChatThreadView`.

### Archetype 11: Structured Workspace Settings & Administration
- **Purpose:** Organized configuration and administrative preferences.
- **Composition:** Clean categorized section tiles, concise descriptions, status toggles, branch selector flyouts, and explicit danger zone styling for account actions.
- **Assigned Screens:** `OwnerSettingsView`, `AdvisorProfileSheet`, `CustomerProfileSettingsView`, `CrmSettingsView`.
