# 00 — Airbnb-Grade Addendum (Customer Layer Only)

**Document ID:** `phases/redesign_v2/00_AIRBNB_GRADE_ADDENDUM.md`  
**Scope:** Customer app ONLY (`apps/customer_app`, Phases 16–18). Staff / Owner / CRM stay enterprise Concept A.  
**Authority:** Extends `00_CONCEPT_A_DESIGN_SYSTEM.md` — never replaces it. On conflict, Concept A tokens win for enterprise; this addendum wins for customer surfaces.  
**Status:** FROZEN ADDENDUM

---

## 1. Intent

Steal Airbnb's *grade* (air, imagery, trust, flow), not its screens. Customer app must feel like booking a stay: imagery-first, one CTA per screen, price transparency, reviews, warm microcopy. Staff consoles keep density — greasy-hands efficiency beats photo galleries.

## 2. Customer-Layer Tokens (additive, `AppDimensions` / theme-adjacent)

- `radiusCustomerCard = 16.0` (vehicle/listing cards), `radiusCustomerSheet = 16.0` (bottom sheets), image ratio `16:10`, image radius matches card.
- Spacing: section gap `28`, card gap `20`, page gutter `20` mobile / `28` tablet (airier than enterprise 24/16/16).
- CTA: single primary per screen, full-width on mobile (`minHeight 52`), cobalt fill stays (brand), white ink, 12px radius.
- Trust accent: success/amber pills for `Guest-Favorite`-equivalents (`Top Rated`, `Verified Workshop`); never random colors.
- Typography: same Jakarta/Plex families; customer titles one step larger than enterprise (card title 16/700, page title 24/800); tabular money unchanged.

## 3. Shared Components (build in `shared_core`, customer-composition first)

1. `AirbnbImageCard` — 16:10 photo top, favorite heart top-end, health/rating badge, title + meta + price row. Empty state = warm illustration + single CTA, never blank box.
2. `PriceBreakdownDock` — sticky bottom dock: line items (service, parts, VAT 5%), total AED tabular, primary CTA + trust line (e.g. free re-check). Used by booking + approvals + invoice.
3. `ReviewRow` — avatar, name, stars, date, tags (`Fast Service`, `Clean Bay`, `Clear Advice`), RTL-safe.
4. `TrustPill` — verified / top-rated / insured badges with icon + label, EN/AR.
5. Sheet motion: 280ms `easeOutCubic` enter + scrim fade; reduced-motion collapses to instant (`AppMotion.resolve`).

All theme-driven (`context.colors` / `context.semanticColors`), EN/AR keys, 48dp targets, 320px overflow-free, VIN/plate/phone/money LTR-locked.

## 4. Per-Screen Mapping (Phases 16–18)

- **P16 Garage/Home (C1–C6):** home = Explore feed: hero image carousel per vehicle, health badge like Guest Favorite, quick-action row (Book/SOS/Invoices/History) as 4 large touch tiles, Active Journey ribbon as trip itinerary. Vehicles tab = listing detail (photo, VIN LTR, odo, insurance countdown, next-service nudge). Profile/notifications = Airbnb profile + inbox categories.
- **P17 Booking/Breakdown (C7–C11):** 4-step wizard as Airbnb booking: vehicle → package (selectable image cards + upfront AED) → calendar slot chips → drop-off/valet toggle; summary card + QR pass + add-to-calendar; success screen like reservation confirmed. Breakdown = emergency variant: one-tap GPS pin, ETA radar, driver contact, hotline.
- **P18 Status/Approvals/Invoice/Feedback (C12–C15):** status = trip timeline (5 stages, ETA, bay, photo evidence carousel from Phase 08); approvals = resolution-center rows with Approve/Decline + live total dock; invoice = nightly-style breakdown + Apple Pay/Card/Counter; feedback = review flow with stars + tags.

## 5. Copy Tone (customer only)

Warm Airbnb voice, professionally translated (no placeholders): e.g. "Your car is in good hands", "Free re-check within 7 days", "Meet your advisor". Staff strings stay terse operational. All keys EN/AR parity, zero hardcoded.

## 6. Non-Goals / Guardrails

- No enterprise tables/rails/breadcrumbs/Cmd+K in customer shell (per 04.1 §3.1). No photo-first density destruction in staff/owner/CRM. No new backend. No fake ratings — badges derive from real data or don't render.
- Acceptance per screen: side-by-side old-vs-new at 390 + 834 EN/AR; must read as warm consumer product, not recolored enterprise form.
