# Phase 4 — Staff advisor inspection & repair orders

## 1. Title + Goal
Tame the most fragile visuals (damage canvas + SVG vehicle map + repair estimates) into a calm stepper flow with honest, testable styling.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: `apps/staff_app/lib/features/advisor/presentation/pages/{choose_inspection_view,inspection_sheet_view,inspection_preview_view,damage_detail_sheet,repair_order_view,RepairOrderPreviewView,real_damage_canvas}.dart`, `inspection_pages/presentation/{vehicle_map/{hud_pin_bridge,vehicle_body_condition_panel,vehicle_inspection_map,vehicle_map_transform},widgets/inspection_widgets}.dart` (+ thin presentation splits only).
Do NOT touch: `inspection_pages/data/models/*`, providers/datasources math (`repair_estimate_math`), PDF/share logic outputs, routing.

## 4. Design principles
C9 form/detail + stepper (AppProgressBar + "Step X of Y"); C8 AppChartCard/DataRow/InfoTooltip/BottomSheet/Dialog; C10 incl. offline/stale for long inspections; C7 subtle motion only (frozen canvas in tests).

## 5. Step-by-step tasks
1. Choose→sheet→preview as stepped form (max 560 width, grouped sections, sticky bottom primary); damage canvas keeps geometry, restyles pins/HUD via tokens (replace `Color(0x`).
2. Vehicle map panels → AppCards + StatusChips (dot + human label + why); technical map IDs into "Advanced details" accordion.
3. Repair order → estimate cards + price_breakdown_dock via tokens; destructive actions (void/delete) into danger-zone; share/PDF keeps behavior, new chrome.
4. Add skeletons mirroring canvas/map layout; error with Try again; partial-failure banners.

## 6. Screen-by-screen plan
- choose_inspection_view: list anatomy with search + pills.
- inspection_sheet_view: long form → stepper sections; inline validation.
- inspection_preview_view + damage_detail_sheet: detail anatomy; title + chips + stat grid + grouped rows.
- repair_order_view + preview: detail + sticky approve CTA; danger zone separated.
- real_damage_canvas + vehicle_map/*: same geometry, token styling, deterministic (no random), semantics summary.

## 7. UX writing rules
Damage/severity terms → plain + tooltip with technical code; confirmations name the object ("Delete '…'?" pattern for destructive).

## 8. Responsive + accessibility checklist
Canvas usable at 320px; 48dp pins/hit areas (visual 20 ok w/ expanded hit); semantics for map/chart; 1.3x reflow; AA on status colors (never color-alone: dot+label).

## 9. QA checklist
- [ ] Zero `Color(0x` in scope; other forbidden greps clean; light+dark; all states; 1.3x/320px; UI-only diff; `flutter analyze` clean

## 10. Definition of done
Update PROGRESS.md (M4), session log, commit message (e.g. `ui(staff-inspection): redesign inspection + repair-order flow`).

## 11. Ask me first
Severity/status taxonomy mapping, which damage codes must stay visible vs tooltip, PDF pixel-fidelity constraints.
