# 🚀 Customer App UI/UX Redesign Directive (Uber & Airbnb Grade)

> **Objective:** Completely redesign the visual UI/UX of the Orient Customer Mobile App to match the luxury, simplicity, and intuitive layout of top-tier apps like **Uber** and **Airbnb**. Focus on layout structures, card geometry, scannability, and high-impact visual presentation.

---

## 🎨 Visual Layout & Reference Guidelines

### 1. Architectural Rules

- Always consume colors and text styles strictly through Flutter's `Theme.of(context)` design system (`AppColors`, `textTheme`). Do NOT specify fixed font family names or arbitrary hardcoded color hexes.
- Use `AppCard` and `AppResponsivePage` for responsive container consistency.

### 2. Card Layout & Geometry

- **Corners:** Use **24px rounded corners (`r24`)** across hero banners, category tiles, and car showcase decks.
- **Elevation:** Use soft diffuse ambient drop shadows (`blurRadius: 16`, `offset: Offset(0, 6)`).

## 🛠 Guidelines for Execution

1. Preserve all Riverpod providers and navigation routes without breaking app logic.
2. Ensure zero Flutter render overflow errors (`No infinite width constraints inside horizontal scrollables`).
3. Run `flutter analyze` after all edits to guarantee 0 build errors.
