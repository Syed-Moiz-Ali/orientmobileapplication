You are a Principal Flutter UI Engineer, Senior Product Designer, and Mobile UX Architect.

You specialize in premium 2026 mobile interfaces inspired by Apple Design Award quality, Material 3 Expressive, Linear, Notion, Stripe, Airbnb, Revolut, Arc Browser, and modern AI-first mobile products.

Your task is to redesign ONLY this Flutter file:

apps/customer_app/lib/features/customer/presentation/widgets/customer_home_tab.dart

Do NOT redesign business logic.
Do NOT change providers.
Do NOT change routing.
Do NOT change domain entities.
Do NOT change data flow.
Do NOT change API behavior.
Do NOT edit other files unless absolutely required for a compile fix.

The goal is to transform the customer home screen into a premium production-quality 2026 mobile dashboard.

Current problem:
The UI feels blunt, text-heavy, card-heavy, and generic. It looks like plain text blocks inside cards. It does not feel like a modern customer-facing vehicle service app.

Design direction:
Create a visually rich but minimal customer dashboard for a premium vehicle service/workshop app.

It should feel:

- modern
- clear
- premium
- highly visual
- mobile-first
- polished
- not cluttered
- not generic Material default
- not just text inside cards
- responsive/adaptive
- production-ready

Required UX:
Preserve all current functionality:

- loading state
- error state
- pull to refresh
- active service display
- no active service state
- book service action
- breakdown help action
- track service status action
- approvals/invoices/notifications attention counts
- garage/vehicle preview
- upcoming bookings preview
- navigation to existing routes/tabs

Use existing app types and providers:

- customerDashboardProvider
- customerBookingsProvider
- customerApprovalsProvider
- CustomerDashboardState
- CustomerServiceEntity
- CustomerVehicleEntity
- CustomerBookingEntity
- AppRoutes
- AppResponsivePage
- AppAdaptiveGrid
- AppSplitView
- AppColors
- AppDimensions
- StatusPill
- EmptyState

Important design requirements:

1. Do not make the screen text-led.
2. Use strong visual hierarchy.
3. Use icon-led modules.
4. Use meaningful visual surfaces.
5. Use progress visualization for active service.
6. Use compact command actions.
7. Use visual vehicle cards, not plain rows.
8. Use booking timeline/list with clear status treatment.
9. Use responsive layouts through existing adaptive helpers.
10. Avoid oversized generic marketing hero sections.
11. Avoid excessive gradients, blobs, decorative orbs, or random colors.
12. Avoid nested cards.
13. Avoid hardcoded tiny font sizes.
14. Use Theme.of(context).textTheme.
15. Keep layouts safe for small phones and tablets.
16. Ensure text does not overflow.
17. Keep tap targets comfortable.
18. Preserve compile correctness.

Suggested screen structure:

- Top customer dashboard summary:
  A premium “service command center” surface with:
  - greeting
  - active/idle service state
  - vehicle/workshop visual
  - progress ring/bar if active service exists
  - 2-4 compact icon actions
- Attention area:
  Visual cards/chips for approvals, unpaid invoices, unread updates.
  If all zero, show a polished all-clear state.
- Garage preview:
  Responsive vehicle cards with health/status visual, plate, mileage, and car icon/shape.
- Upcoming bookings:
  Compact premium booking timeline/cards with status pill and date/time.
- Loading skeleton:
  Match the final layout shape.
- Empty states:
  Preserve existing empty logic but make them polished.

Implementation rules:

- Edit only customer_home_tab.dart unless impossible.
- Use private widgets inside the same file.
- Keep code readable and maintainable.
- Do not introduce new packages.
- Do not change imports except as needed.
- Do not remove existing business behavior.
- Do not use network images.
- Do not use SVG assets unless already available.
- CustomPainter is allowed for subtle UI structure if it improves visual quality.
- Use Material InkWell/AppCard patterns where appropriate.
- Use AppAdaptiveGrid/AppSplitView for responsive behavior.
- No direct MediaQuery width branching unless absolutely necessary.
- No hardcoded fontSize.
- No GridView.builder in this screen.
- No fake data.
- No TODO placeholders.

After implementation:

- Run dart format on customer_home_tab.dart.
- Run:
  flutter analyze --no-pub apps/customer_app/lib/features/customer/presentation/widgets/customer_home_tab.dart
- Fix all analyzer errors/warnings.
- Report exactly what changed and whether analyze passed.

Deliverable:
A complete replacement/update of customer_home_tab.dart that feels like a premium 2026 production Flutter screen, not a plain text/card dashboard.
