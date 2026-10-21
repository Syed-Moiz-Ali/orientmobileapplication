# UX Brief TEMPLATE (copy for each screen; all sections mandatory)

## User goal
One task per screen: who opens this, what do they need, what single action completes it.

## Single primary action
Exactly one. Name it + its destination.

## Top 3 tasks with tap counts (mandatory; BEFORE = current UI, AFTER = this brief)
1. … — before N taps (list each tap + scroll) → after M taps (M ≤ N; most frequent ≤ 2)
2. …
3. …

## U0-U14 checklist (all must hold; ANY violation caps at 8/16, no exceptions)
U0 least effort / U1 search icon top-right → full-screen search / U2 first actionable item above fold
at 360x800 idle / U3 tap counts above / U4 create/scan reachable lower-half or sticky / U5 no truncation
(wrap ≤2, fit or clean peek) / U6 calm empty (no filled CTA to nothing) / U7 one path per task /
U8 relevance (completed never under Assigned; data issues → LOGIC_FOLLOWUPS.md) / U9 consistency /
U10 feedback + destructive confirm/undo / U11 readable numbers (0 never "-") / U12 one background /
U13 new-employee labels / U14 a11y (48dp, AA, Semantics, 1.3x, 320px).

## What is REMOVED or moved
List every removed structure and where secondary paths go (sheet/overflow/tabs). Legacy widgets
removed at zero usages (record in WIDGET_MIGRATION_MAP.md). No logic changes.

## Flow / sections
C16 structure for the screen kind. Steps only where the task is a flow.

## Hard-reject checklist (all must hold; reviewer caps at 10/16 on ANY violation)
- [ ] Borderless light cards (shadow/flat + whitespace); dark may use border
- [ ] No orphan tiles (3 equal cols or h-scroll row)
- [ ] ONE filled accent per section
- [ ] One path per task (no duplicate entry points)
- [ ] No permanent status pills (abnormal → AppBanner)
- [ ] Badges offset outside icons, clear area kept
- [ ] No ALL CAPS; no label/badge number duplication
- [ ] Search = one top pill → full search screen/sheet (never inline mid-page)
- [ ] Above the fold: first primary item visible at 360x800 idle (wireframe below proves it)
- [ ] Card hierarchy: recognizable title → status pill → meta (IDs are meta)
- [ ] Carousels peek or are lists

## ASCII wireframe at 360x800 (mandatory; first primary item above the bottom nav)
```
(draw the fold line; the first work order / hero + first item must sit above it)
```

## States
loading (mirroring skeleton), empty (icon + sentence + action), error + Try again,
offline/stale (AppBanner + last data), dark, RTL ar, 320px + 1.3x, tablet widths.

## Copy keys needed
Reuse existing keys; new keys only where C16 copy requires (en+ar, listed for phase 9).
