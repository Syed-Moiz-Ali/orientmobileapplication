# Orient Workshop Product UX

## Product Model

Orient Workshop is a role-based workshop operating system. The product is split into focused apps because each role has different urgency, context, and screen density needs.

## Users And Goals

### Customer

Customers use the app to book service, request breakdown help, track repair progress, approve estimates, pay invoices, manage vehicles, and send feedback.

Primary goals:
- Know what is happening with my vehicle.
- Book or request help quickly.
- Approve work only when the decision is clear.
- Find invoices, vehicles, and garage contact options without calling repeatedly.

### Advisor

Advisors coordinate front-desk workshop flow: check-ins, customer details, inspections, repair orders, approvals, reminders, and delivery.

Primary goals:
- See what requires action now.
- Create or continue a job card with minimal repeated entry.
- Keep customer, vehicle, inspection, and estimate data connected.
- Move work from check-in to delivery without losing context.

### Technician

Technicians focus on assigned jobs, task progress, parts requests, escalations, attendance, and job details.

Primary goals:
- Start the next right job quickly.
- Update task state with low friction.
- Request parts or escalate blockers with clear feedback.
- See job instructions and customer-approved work without clutter.

### Supervisor

Supervisors monitor queue health, technician allocation, quality checks, scheduling, staff performance, and reports.

Primary goals:
- Detect bottlenecks before they become customer delays.
- Assign or rebalance work.
- Review quality and approve operational exceptions.
- Understand daily capacity and risk.

### Owner

Owners need business visibility and control: sales, job status, approvals, receivables, inventory, documents, feedback, team, and subscription.

Primary goals:
- Understand today’s business health.
- Act on money, operational, or compliance risks.
- Drill into job cards and team performance.
- Avoid dashboards full of decorative metrics.

### CRM User

CRM users manage leads, follow-ups, pipeline, conversations, integrations, team activity, reports, and settings.

Primary goals:
- Prioritize leads that need action.
- Move leads through the pipeline.
- Keep follow-ups and conversations visible.
- Understand acquisition channels and sales team performance.

## Navigation Architecture

Mobile uses a bottom navigation pattern for frequent destinations and full-screen flows for complex tasks. Tablet uses rail or split-view patterns where the task benefits from list/detail. Desktop/web uses persistent navigation and constrained content so operational screens remain scannable.

Primary destinations:
- Customer: Home, Bookings, Approvals, Vehicles, Status.
- Advisor: Today, Jobs, Approvals, Reports, Profile/context actions.
- Technician: Today, Jobs, Attendance, Productivity, Help/escalations.
- Supervisor: Queue, Assignments, QC, Schedule, Reports.
- Owner: Overview, Job Cards, Receivables, Inventory, Team.
- CRM: Leads, Tasks, Conversations, Reports, Settings.

Secondary destinations belong behind contextual actions, sheets, or detail pages unless they are repeated daily workflows.

## Critical Journeys

### Customer Service Booking

Entry: Home primary action or Vehicles.
Discovery: Pick vehicle and service.
Decision: Choose date/time and review garage details.
Action: Confirm booking.
Feedback: Inline loading, success page, booking reference.
Completion: Return to bookings with the new appointment visible.

### Authentication

Entry: App launch or expired session.
Discovery: User sees the brand, clear sign-in purpose, and one primary input.
Decision: Choose secure code or password.
Action: Submit email/phone, code, or password.
Feedback: Inline validation, button loading, and code resend state.
Completion: Route to the correct role workspace without showing irrelevant role choices.

### Customer Approval

Entry: Home attention area or Approvals tab.
Discovery: See estimate summary, safety impact, and price.
Decision: Approve, reject, or ask for clarification.
Action: Confirm high-impact decision.
Feedback: Status update and next expected workshop action.
Completion: Track job progress.

### Advisor Check-In To Repair Order

Entry: Advisor Today primary action.
Discovery: Search/scan vehicle or select booking.
Decision: Confirm customer and vehicle details.
Action: Create inspection and repair order.
Feedback: Saved draft/progress indicators.
Completion: Job moves into workshop queue.

### Technician Job Execution

Entry: Technician Today.
Discovery: Pick highest-priority assigned job.
Decision: Review approved work and blockers.
Action: Start, update progress, request parts, or escalate.
Feedback: Immediate status confirmation.
Completion: Job moves to review/QC.

### Owner Risk Review

Entry: Owner Overview.
Discovery: Attention list for overdue invoices, expiring docs, low stock, blocked jobs.
Decision: Open details or assign follow-up.
Action: Approve, contact, restock, or delegate.
Feedback: Updated count and visible activity.
Completion: Risk is removed from attention list.

### CRM Lead Conversion

Entry: Leads or Tasks.
Discovery: Prioritized lead card with channel and next action.
Decision: Call/message/assign/update stage.
Action: Log interaction and schedule follow-up.
Feedback: Stage and activity timeline update.
Completion: Lead becomes booking/opportunity or is closed.

## Screen Hierarchy

Every home screen should start with:
- Role-specific attention: what needs action today.
- One primary action.
- Recently changed or blocked work.
- Quick access to common workflows.

Detail screens should start with:
- Entity identity and status.
- Most important next action.
- Key facts needed for a decision.
- Timeline/history after the decision content.

Forms should group fields by user decision, not database shape. Known values must be prefilled and complex tasks should use progressive disclosure.
