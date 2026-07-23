# HydroQ — Design System

**Document status:** Approved for implementation
**Version:** 1.1
**Date:** 23 July 2026
**Product name:** HydroQ
**Primary platform:** Flutter mobile application
**Theme scope:** Light theme only for MVP
**Product language:** Indonesian
**Reference image:** [`references/mobile-design-reference.png`](references/mobile-design-reference.png)

---

## 1. Purpose

This document defines the visual language, interaction patterns, reusable components, layout rules, status presentation, accessibility requirements, and Flutter token structure for HydroQ.

The design adapts the strongest qualities of the supplied mobile reference:

- White-first layouts with generous negative space.
- A bright botanical green as the primary action color.
- Rounded surfaces and friendly geometry.
- Soft, controlled elevation rather than heavy shadows.
- Compact but readable mobile cards.
- Clear hierarchy built through spacing and typography instead of decoration.
- A calm, approachable tone suitable for beginners.

The product must not look like a healthcare application with replaced text. The reference is translated into a hydroponic identity through plant imagery, water-quality metrics, sensor states, nutrient terminology, reservoir visualizations, and agriculture-focused content.

### Source-of-Truth Order

When requirements conflict, use this priority:

1. `PRD.md` for product scope and acceptance requirements.
2. `DESIGN_SYSTEM.md` for visual, component, interaction, and accessibility rules.
3. `docs/superpowers/specs/2026-07-23-hydroq-monitoring-app-design.md` for detailed screen behavior and architecture.
4. `docs/superpowers/plans/2026-07-23-hydroq-flutter-mvp-implementation.md` for task order and implementation steps.

---

## 2. Design Principles

### 2.1 Condition First

The current water condition must be understandable within five seconds. pH, nutrient concentration, volume, device state, and data freshness always appear before historical detail.

### 2.2 Friendly, Not Childish

Rounded shapes, plant imagery, and plain language should make the product approachable. Avoid cartoonish decoration, excessive mascots, or playful treatments that weaken trust in critical sensor information.

### 2.3 Calm by Default, Urgent When Necessary

Normal screens should feel quiet and stable. Warning and critical states must become more prominent through color, iconography, text, and placement without turning the whole screen into an alarm panel.

### 2.4 Progressive Disclosure

Beginners see understandable summaries first. Exact values, trends, ranges, timestamps, and recipe controls remain accessible without dominating the initial view.

### 2.5 Never Misrepresent Freshness

Old values must never appear as live readings. Stale, offline, cached, partial, and unavailable states always include text and timestamps.

### 2.6 Color Supports Meaning; It Does Not Carry Meaning Alone

Every semantic state includes a label and icon in addition to color.

### 2.7 Consistency Over Novelty

Use the documented components and spacing rhythm. Do not create one-off cards, unique paddings, or new green shades for individual screens.

---

## 3. Brand Personality

The product should feel:

- **Fresh:** botanical green, clean surfaces, plant imagery.
- **Reliable:** stable hierarchy, clear timestamps, explicit device state.
- **Helpful:** beginner-friendly explanations and corrective context.
- **Technical enough:** precise values, units, ranges, and reports for experienced growers.
- **Calm:** limited color use, controlled motion, and ample spacing.

The product should not feel:

- Industrial or laboratory-heavy.
- Neon, cyberpunk, or dark by default.
- Overly decorative.
- Like an ecommerce catalog.
- Like a social-media application.
- Like a copied health product.

---


### 3.1 Product Name and Wordmark

- The official product name is **HydroQ**.
- Always preserve the capital `H` and `Q`. Never write `Hydroq`, `Hydro Q`, or the former generic application name in user-facing UI.
- The MVP uses a text-only `HydroQ` wordmark in Poppins SemiBold. Do not improvise a standalone symbol, monogram, or mascot during MVP implementation.
- Use the wordmark on the splash and authentication entry screen only. Authenticated screens use normal page titles rather than repeatedly displaying the brand.
- Notification titles may start with `HydroQ` when platform context would otherwise be unclear.

## 4. Color System

### 4.1 Core Palette

| Token | Hex | Primary use |
|---|---:|---|
| `green-50` | `#ECF9F0` | Soft selected backgrounds, informational panels |
| `green-100` | `#D8F3E1` | Hover/pressed background, subtle metric accents |
| `green-200` | `#B5E7C6` | Dividers inside green surfaces, disabled accent decoration |
| `green-300` | `#7FD49B` | Decorative chart area and secondary data marks |
| `green-400` | `#3DC469` | Secondary green emphasis |
| `green-500` | `#12B347` | Primary brand and action color |
| `green-600` | `#0D963B` | Pressed primary state, active icon emphasis |
| `green-700` | `#087A32` | High-contrast accent text |
| `green-800` | `#075F2A` | Dark botanical accent |
| `green-900` | `#064921` | Rare high-contrast brand detail |

### 4.2 Neutral Palette

| Token | Hex | Primary use |
|---|---:|---|
| `neutral-0` | `#FFFFFF` | Cards, input surfaces, modal surfaces |
| `neutral-25` | `#FBFCFB` | Very subtle nested background |
| `neutral-50` | `#F7F9F7` | Main application background |
| `neutral-100` | `#F0F3F1` | Disabled surface, skeleton base |
| `neutral-200` | `#E5EAE7` | Borders and dividers |
| `neutral-300` | `#D1D8D4` | Strong border and disabled icon |
| `neutral-400` | `#A6AEA9` | Placeholder text |
| `neutral-500` | `#747C77` | Secondary text |
| `neutral-600` | `#5D655F` | Supporting text with stronger contrast |
| `neutral-700` | `#414843` | Body text |
| `neutral-800` | `#292F2B` | Titles and primary text |
| `neutral-900` | `#171B18` | Highest-emphasis text |

### 4.3 Semantic Palette

| Token | Hex | Soft background | Use |
|---|---:|---:|---|
| `success` | `#159447` | `#EAF7EF` | Normal condition, recovery, successful action |
| `warning` | `#D98200` | `#FFF4DD` | Approaching threshold, attention required |
| `critical` | `#C9363E` | `#FDEBED` | Unsafe persistent reading, destructive action |
| `information` | `#2676C9` | `#EAF3FC` | Guidance, neutral informational notice |
| `offline` | `#6F7772` | `#EFF1F0` | Offline device, unavailable value |
| `stale` | `#A26312` | `#FFF3E3` | Delayed or cached data |

### 4.4 Application Semantic Tokens

| Token | Value |
|---|---|
| `color.background` | `neutral-50` |
| `color.surface` | `neutral-0` |
| `color.surfaceSubtle` | `neutral-25` |
| `color.primary` | `green-500` |
| `color.primaryPressed` | `green-600` |
| `color.primarySoft` | `green-50` |
| `color.onPrimary` | `neutral-0` |
| `color.textPrimary` | `neutral-900` |
| `color.textSecondary` | `neutral-500` |
| `color.textTertiary` | `neutral-400` |
| `color.border` | `neutral-200` |
| `color.divider` | `neutral-100` |
| `color.focusRing` | `green-300` |

### 4.5 Color Usage Rules

- Green is reserved for brand, active navigation, positive status, and primary actions.
- Do not make every card green. Most surfaces remain white.
- Use a maximum of one solid green primary action in each visible section.
- Warning and critical colors may not be replaced with pale green.
- Critical actions use the critical color only when the action is destructive or safety-related.
- Chart lines use green for the selected parameter. Threshold regions use semantic warning and critical tints.
- Avoid gradients in the MVP. A single subtle tonal background may be used only in onboarding illustrations, not data cards.

---

## 5. Typography

### 5.1 Typeface

**Primary typeface:** Poppins
**Fallback:** platform sans-serif

Poppins matches the rounded, friendly character of the visual reference while retaining enough clarity for technical values.

Use bundled font assets in production to avoid layout differences between devices. If the harness cannot load Poppins immediately, use the platform sans-serif temporarily without changing component dimensions.

### 5.2 Type Scale

| Style token | Size | Height | Weight | Usage |
|---|---:|---:|---:|---|
| `displayLarge` | 32 | 40 | 600 | Rare onboarding headline |
| `headlineLarge` | 28 | 36 | 600 | Primary numerical or page emphasis |
| `headlineMedium` | 24 | 32 | 600 | Page title |
| `titleLarge` | 20 | 28 | 600 | Main section title |
| `titleMedium` | 18 | 26 | 600 | Card section heading |
| `titleSmall` | 16 | 24 | 500 | Card title, list title |
| `bodyLarge` | 16 | 24 | 400 | High-priority body text and form input |
| `bodyMedium` | 14 | 22 | 400 | Default body copy |
| `bodySmall` | 12 | 18 | 400 | Supporting copy and timestamps |
| `labelLarge` | 14 | 20 | 600 | Button and selected control labels |
| `labelMedium` | 12 | 18 | 500 | Badges, tabs, metadata |
| `labelSmall` | 11 | 16 | 500 | Compact chart labels only |
| `sensorValue` | 30 | 36 | 600 | Current pH, EC, or volume value |
| `sensorUnit` | 13 | 18 | 500 | Unit aligned with sensor value |

### 5.3 Typography Rules

- Use sentence case for all Indonesian UI labels.
- Do not use all caps for section headings or buttons.
- Use `FontFeature.tabularFigures()` for live readings, report statistics, percentages, timestamps, and ranges.
- Keep line length below approximately 60 characters for explanatory content on mobile.
- Use no more than three weights on one screen: regular, medium, and semibold.
- Do not use font weight as the only distinction between clickable and non-clickable text.
- Primary numerical values always include an explicit unit nearby unless the unit is part of the metric name, such as pH.

---

## 6. Spacing and Layout

### 6.1 Eight-Point Spacing Scale

| Token | Value |
|---|---:|
| `space.0` | 0 |
| `space.0_5` | 4 px |
| `space.1` | 8 px |
| `space.1_5` | 12 px |
| `space.2` | 16 px |
| `space.2_5` | 20 px |
| `space.3` | 24 px |
| `space.4` | 32 px |
| `space.5` | 40 px |
| `space.6` | 48 px |
| `space.8` | 64 px |

### 6.2 Screen Layout

- Horizontal page padding: `20 px` on standard phones.
- Horizontal page padding: `24 px` when logical width is at least `600 px`.
- Top content gap below app bar: `16 px`.
- Gap between major sections: `24 px`.
- Gap between closely related controls: `8–12 px`.
- Card internal padding: `16 px` for compact cards and `20 px` for primary cards.
- Bottom content padding above navigation: at least `24 px`.
- Respect system safe areas on all screens.

### 6.3 Responsive Breakpoints

| Width | Behavior |
|---|---|
| `< 360 px` | Compact phone: reduce card padding to 16 px; avoid side-by-side metric controls |
| `360–599 px` | Standard phone layout |
| `600–839 px` | Large phone/small tablet: expand margins and allow wider two-column layouts |
| `≥ 840 px` | Tablet: constrain readable content width to 720 px; center the main column |

The MVP remains phone-first. Tablet behavior should be usable, not separately redesigned.

### 6.4 Grid Rules

- Education uses a two-column plant grid on standard phones.
- Education falls back to one column below `340 px` if card content becomes cramped.
- Main sensor summary remains one large card with three internal metric regions.
- Metric regions may form a row on wide screens and a stacked layout on compact screens.
- Avoid horizontal scrolling for primary dashboard content.

---

## 7. Shape, Border, and Elevation

### 7.1 Corner Radius

| Token | Value | Usage |
|---|---:|---|
| `radius.small` | 8 px | Small chips and compact internal controls |
| `radius.medium` | 12 px | Text fields, segmented controls, buttons |
| `radius.large` | 16 px | Standard cards and list surfaces |
| `radius.xLarge` | 24 px | Main sensor card and large bottom sheet |
| `radius.full` | 999 px | Pills, circular badges, progress tracks |

### 7.2 Borders

- Standard card border: `1 px neutral-100`.
- Input default border: `1 px neutral-200`.
- Input focused border: `1.5 px green-500`.
- Error input border: `1.5 px critical`.
- Do not combine strong borders and strong shadows on the same surface.

### 7.3 Elevation

| Token | Shadow specification | Usage |
|---|---|---|
| `elevation.none` | none | Embedded content and flat lists |
| `elevation.low` | `0 2 10 rgba(23,27,24,0.05)` | Cards |
| `elevation.medium` | `0 8 24 rgba(23,27,24,0.09)` | Floating bottom navigation, popovers |
| `elevation.high` | `0 18 40 rgba(23,27,24,0.14)` | Modal or bottom sheet only |

Use shadows sparingly. A card may be defined by a subtle border without a shadow when many cards appear together.

---

## 8. Iconography and Imagery

### 8.1 Icons

- Use Material Symbols Rounded or an equivalent rounded icon family.
- Standard icon size: `24 px`.
- Compact metadata icon: `18–20 px`.
- Large state icon: `40–48 px`.
- Icon strokes should feel consistent and not mix filled and outlined styles arbitrarily.
- Active bottom-navigation icons may use filled variants; inactive icons use outlined variants.

Recommended semantic icons:

| Meaning | Icon concept |
|---|---|
| Home | house or dashboard |
| Education | leaf or menu book |
| Profile | person |
| pH | droplet with indicator |
| EC/TDS | activity, waves, or nutrient flask |
| Volume | reservoir or water level |
| Online | cloud done or Wi-Fi |
| Offline | cloud off or Wi-Fi off |
| Warning | warning triangle |
| Critical | error octagon or circle |
| Recovery | check circle |
| Stale | schedule or history toggle |

### 8.2 Plant Photography

Plant images are most prominent on the Education page.

Requirements:

- Use a consistent `4:3` or `1:1` crop across all plant cards.
- Prefer clean backgrounds or naturally soft environmental backgrounds.
- Keep the plant as the clear focal subject.
- Avoid watermarks, text baked into images, and inconsistent lighting.
- Do not combine photorealistic plants with cartoon illustrations in the same grid.
- Use `BoxFit.cover` with a predictable focal point.
- Provide a neutral plant placeholder when an image fails.
- Each image must have a meaningful semantic label for accessibility where supported.

### 8.3 Illustrations

Illustrations may be used for onboarding, empty states, and configuration guidance. Use simple botanical forms, water droplets, reservoirs, and sensor motifs. Limit each illustration to a small palette based on green and neutrals.

---

## 9. Interaction States

Every interactive component supports the following states when applicable:

- **Default**
- **Pressed**
- **Focused**
- **Disabled**
- **Loading**
- **Error**
- **Selected**

### State Rules

- Pressed state uses a darker fill or subtle opacity change, not scale-only feedback.
- Focus state uses a visible `green-300` ring with at least `2 px` visual thickness.
- Disabled controls remain readable and cannot appear selected.
- Loading buttons retain their width and replace the label area with a compact progress indicator.
- Tappable elements have a minimum target size of `44 × 44 px`, preferably `48 × 48 px`.

---

## 10. Core Components

## 10.1 Primary Button

**Purpose:** The strongest action in a section or screen.

**Specification**

- Height: `52 px`.
- Horizontal padding: `20 px`.
- Radius: `12 px`.
- Fill: `green-500`.
- Label: `labelLarge`, white.
- Pressed fill: `green-600`.
- Disabled fill: `neutral-200`; disabled label: `neutral-400`.
- Full width on authentication and form submission screens.

**Examples:** `Masuk`, `Simpan resep`, `Gunakan profil ini`.

Do not show two solid primary buttons next to each other.

## 10.2 Secondary Button

- Height: `48–52 px`.
- White or transparent surface.
- Border: `neutral-200`.
- Label and icon: `green-700` or `neutral-800`, depending on context.
- Used for alternative actions such as `Salin sebagai resep kustom`.

## 10.3 Text Button

- Minimum target: `44 px` height.
- No container unless needed for focus visibility.
- Green label for non-destructive actions.
- Critical label only for destructive actions.
- Examples: `Lihat semua`, `Lupa kata sandi?`.

## 10.4 Icon Button

- Target size: `44–48 px`.
- Visual container: optional `40 px` rounded square or circle.
- Use soft green background for highlighted non-destructive actions.
- Always provide a semantic label or tooltip.

## 10.5 Text Field

- Minimum height: `52 px`.
- Radius: `12 px`.
- Default background: `neutral-50` or white.
- Default border: `neutral-200`.
- Label above the field is preferred over placeholder-only labeling.
- Helper/error text appears below with `bodySmall`.
- Password fields include a show/hide icon button.
- Prefix icons are optional and must not replace labels.

## 10.6 Search Field

Used only on Education in the MVP.

- Height: `48 px`.
- Leading search icon.
- Placeholder: `Cari tanaman hidroponik`.
- Clear button appears when text is present.
- Search results update after a short debounce or on submitted text.
- No category-filter control is displayed.

## 10.7 Main Sensor Summary Card

**Purpose:** The primary dashboard surface.

**Structure**

1. Tank status header.
2. Device/freshness metadata.
3. Three metric regions: pH, EC/TDS, and volume.
4. Contextual callout when action is required.

**Visual specification**

- White surface.
- Radius: `24 px`.
- Padding: `20 px`.
- Border: `neutral-100`.
- Elevation: low.
- Metric regions are separated by spacing or subtle dividers, never heavy boxes.
- Aggregate status appears as icon plus badge and text.

**Status priority**

1. Critical.
2. Offline.
3. Data incomplete.
4. Stale.
5. Warning.
6. Normal.

The backend remains authoritative for status values.

## 10.8 Sensor Metric Item

Each metric item displays:

- Metric name.
- Current value.
- Unit.
- Target range.
- Status label and icon.
- Sensor timestamp when needed.

Example:

```text
pH
6.2
Target 5.5–6.5
Normal
```

For EC/TDS:

```text
Nutrisi
1.8 mS/cm
1.150 ppm
Target EC 1.2–1.8
Warning
```

Rules:

- EC is the primary value; TDS is supporting information.
- Use an em dash for unavailable values, never `0`.
- Cached or stale values include age, such as `Diperbarui 8 menit lalu`.
- Metric values use tabular figures.

## 10.9 Status Badge

| State | Background | Foreground | Icon |
|---|---|---|---|
| Normal | success soft | success | check circle |
| Warning | warning soft | warning | warning triangle |
| Critical | critical soft | critical | error |
| Stale | stale soft | stale | schedule |
| Offline | offline soft | offline | cloud off |
| Incomplete | information soft | information | sensors off |

- Height: approximately `28–32 px`.
- Horizontal padding: `10–12 px`.
- Radius: full.
- Label: `labelMedium`.
- Badge text is always visible; icon-only status is prohibited.

## 10.10 Device Status Indicator

A compact row containing:

- Connection icon.
- State label: `Online`, `Offline`, `Data terlambat`, or `Belum dikonfigurasi`.
- Last-contact time when offline or stale.

Do not use a green dot alone. The state must be written.

## 10.11 Volume Progress Indicator

- Track height: `8–10 px`.
- Rounded ends.
- Normal fill: green.
- Warning fill: warning.
- Critical fill: critical.
- Percentage and liter value remain visible as text.
- If volume is unavailable, show a neutral empty track and `Data tidak tersedia`.

## 10.12 Segmented Control

Used for:

- Report parameter: `pH`, `EC/TDS`, `Volume`.
- Period: `Hari`, `Minggu`, `Bulan`.

Specification:

- Height: `40–44 px`.
- Selected segment: green soft background with green-700 label.
- Unselected: neutral text and transparent/white background.
- Radius: `12 px` for outer group.
- Use a horizontally scrollable control only if localization or accessibility text scaling makes labels overflow.

## 10.13 Report Chart Container

- The chart itself sits on a transparent or white surface without decorative gradients.
- One selected metric appears at a time.
- Primary line: green-500, `2.5–3 px`.
- Data points: optional on daily view; avoid clutter on monthly view.
- Grid lines: neutral-100.
- Axis labels: neutral-500, `labelSmall`.
- Safe range: subtle green-50 band.
- Warning threshold: warning dashed line.
- Critical threshold: critical dashed line when useful.
- Tooltip includes timestamp, exact value, unit, and state.
- Empty charts show an explanatory empty state rather than an empty coordinate grid.
- Do not smooth lines so aggressively that peaks or threshold crossings become misleading.

## 10.14 Statistic Tile

Used below or beside report charts.

- Label: average, minimum, maximum, warnings, critical events, or unsafe duration.
- Value: `titleMedium` or `headlineMedium` depending on emphasis.
- Neutral surface, compact spacing.
- Avoid unique colors for each statistic unless the statistic is semantic.

## 10.15 Alert List Item

Displays:

- Parameter icon.
- Severity label.
- Reading and target range.
- Start time.
- Duration or `Masih berlangsung`.
- Recovery status when resolved.
- Chevron when a detail screen exists.

Critical items use a narrow critical accent, not a full red card. Resolved items use a recovery label without hiding the original severity.

## 10.16 Plant Education Card

**Layout:** two-column grid on standard phones.

**Content**

- Plant image.
- Plant name.
- Difficulty label: `Pemula`, `Menengah`, or `Lanjutan`.
- pH range.
- EC range.

**Specification**

- Radius: `16 px`.
- White surface.
- Image aspect ratio: `4:3` or square, consistent throughout the grid.
- Internal padding: `12 px`.
- Name uses `titleSmall` and may wrap to two lines.
- Entire card is tappable.
- No category filters in the MVP.

## 10.17 Plant Detail Information Card

Recommended content sequence:

1. Hero image and plant name.
2. Difficulty and estimated harvest duration.
3. pH range.
4. EC range and estimated TDS.
5. Water-temperature guidance when data exists.
6. Nutrition and maintenance tips.
7. Common issues.
8. Primary action: `Gunakan profil ini`.
9. Secondary action: `Salin sebagai resep kustom`.

Use grouped white cards separated by `16–24 px`, not one extremely long card.

## 10.18 Profile Menu Tile

- Leading icon in a `40 px` green-soft rounded container.
- Title.
- Optional supporting description.
- Trailing chevron or current value.
- Minimum height: `64 px`.
- Dividers are optional when tiles share one grouped surface.

## 10.19 Bottom Navigation

The navigation contains exactly:

1. `Beranda`
2. `Edukasi`
3. `Profil`

Specification:

- Height: approximately `72–80 px`, including safe area.
- White surface.
- Top border or medium soft shadow, not both strongly.
- Active icon and label: green-500 or green-600.
- Inactive icon and label: neutral-400/500.
- Both icon and text remain visible.
- Do not use a central floating action button.
- Do not add Reports as a fourth tab.

## 10.20 App Bar

- Background: transparent or application background.
- Page title aligned left.
- No unnecessary centered logo on authenticated screens.
- Back icon on nested pages.
- One or two actions maximum.
- Home header may include greeting, tank name, and notification action instead of a standard app bar.

## 10.21 Bottom Sheet and Dialog

Use a bottom sheet for mobile-focused selection and short forms. Use a dialog for confirmation.

- Bottom sheet radius: `24 px` at the top corners.
- Dialog radius: `20 px`.
- Destructive confirmation includes a clear action consequence.
- Do not use a dialog for routine navigation.

## 10.22 Snackbar

- Used for transient confirmation or recoverable failure.
- Duration: `3–5 seconds`.
- Includes an optional action such as `Coba lagi`.
- Critical ongoing sensor states belong in the page UI and notification system, not only a snackbar.

## 10.23 Skeleton Loading

- Match the final layout shape to minimize movement.
- Use neutral-100 base and a subtle neutral highlight.
- Do not display fake values during loading.
- Avoid animated skeletons when the user has reduced-motion preferences enabled.

## 10.24 Empty State

Each empty state includes:

- Small relevant illustration or icon.
- Clear title.
- One-sentence explanation.
- A primary or secondary action when the user can resolve it.

Examples:

- No plant selected: `Belum ada profil tanaman aktif`.
- No reports: `Data belum cukup untuk membuat laporan`.
- No alerts: `Belum ada peringatan`.
- No device: `Perangkat belum terhubung`.

## 10.25 Error State

- Keep valid cached content visible where possible.
- Explain whether the failure affects network data, one sensor, or all readings.
- Provide retry only when retrying can help.
- Do not replace an entire dashboard with a generic error if two of three sensors remain available.

---

## 11. Screen Composition Patterns

## 11.1 Authentication

- Light background.
- Brand mark or simple hydroponic illustration near the top.
- Concise welcome title.
- Email and password fields.
- Full-width green primary button.
- Password recovery as text action.
- No social-login buttons in MVP.
- Keep the keyboard flow logical and use appropriate input types.

## 11.2 Beranda

Recommended order:

1. Greeting or concise header.
2. Tank name and active plant/recipe.
3. Device status and update age.
4. Main sensor summary card.
5. Report preview with metric and period controls.
6. Statistic tiles.
7. Recent alerts.
8. Bottom navigation.

Do not place Education cards on Home. Do not move reports to another primary tab.

## 11.3 Detailed Report

- App bar with back navigation and page title.
- Parameter segmented control.
- Period control.
- Date range summary.
- Main chart.
- Statistics.
- Threshold and out-of-range summary.
- Partial/empty state when applicable.

## 11.4 Alert History

- Chronological list, newest first.
- Optional state control such as `Semua`, `Berlangsung`, `Selesai` only if needed after real data exists.
- Severity remains visible in every row.
- Resolved state does not remove the original event context.

## 11.5 Edukasi

- Page title and short introductory copy.
- Search field.
- Two-column plant grid.
- No filter chips, category tabs, or sorting controls in the MVP.
- Loading, empty-search, and offline-cache states.

## 11.6 Plant Detail

- Prominent plant image.
- Name, difficulty, and short description.
- Recommended parameter summary.
- Practical tips in scannable sections.
- Sticky or bottom-aligned primary action only if it does not cover content.

## 11.7 Profil

- User identity summary.
- Grouped settings tiles:
  - Tank configuration.
  - Device status.
  - Active plant profile.
  - Custom recipes.
  - Notification preferences.
  - Unit preferences.
  - Change password.
- Logout appears as a separate lower-emphasis destructive action.

---

## 12. Sensor and System States

### 12.1 Normal

- Green success badge.
- Current value and target range.
- No corrective callout required.

### 12.2 Warning

- Warning badge and icon.
- Explain which limit is approaching.
- Show current value and target.
- Avoid alarming copy such as `Bahaya`.

Example: `EC mendekati batas atas`.

### 12.3 Critical

- Critical badge and icon.
- Place the affected parameter first in the card.
- Provide actionable but non-prescriptive wording unless backend content supplies a recommendation.
- Maintain high contrast.

Example: `pH berada di luar rentang aman`.

### 12.4 Recovered

- Success icon and text.
- Preserve previous event history.
- Example: `Volume air kembali stabil`.

### 12.5 Stale Data

- Show the last known values only with a visible stale label.
- Display `Diperbarui X menit lalu`.
- Do not animate the values as live.
- Report chart may remain available if historical data exists.

### 12.6 Offline Device

- Show offline state and last contact time.
- Current values become visually secondary and clearly labeled as the last known readings.
- Provide device-status navigation where relevant.

### 12.7 Partial Sensor Failure

- Keep healthy metrics visible.
- Failed metric displays an em dash and `Sensor tidak tersedia`.
- Overall state becomes `Data tidak lengkap` unless a healthy metric is critical.

### 12.8 Unconfigured State

- Explain what is missing: tank capacity, active profile, or device link.
- Provide one clear action to continue setup.

---

## 13. Data Freshness Presentation

Every dashboard snapshot exposes freshness in human-readable form:

- `Baru saja`
- `Diperbarui 12 detik lalu`
- `Diperbarui 4 menit lalu`
- `Data terakhir: 22 Jul 2026, 21.32`

Rules:

- Use relative time for recent data and exact time for older/offline data.
- If metric timestamps differ, show per-metric timestamps for affected sensors.
- Realtime animations must not restart if the numeric value is unchanged.
- The frontend does not infer authoritative safe/unsafe states from raw values.

---

## 14. Motion

### 14.1 Duration

| Token | Duration | Use |
|---|---:|---|
| `motion.fast` | 120 ms | Press feedback, icon-state change |
| `motion.standard` | 200 ms | Tab, badge, and small layout transition |
| `motion.slow` | 320 ms | Page section entrance or bottom sheet |

### 14.2 Curves

- Standard entrance: `easeOutCubic`.
- Exit: `easeInCubic`.
- Value transition: `easeOut`.

### 14.3 Rules

- Animate sensor number changes subtly with cross-fade or short count transition.
- Do not continuously pulse normal readings.
- A critical indicator may pulse once when first received, not indefinitely.
- Respect reduced-motion settings by removing non-essential animation.
- Avoid parallax, large card scaling, bouncing navigation, and ornamental loading sequences.

---

## 15. Accessibility

### 15.1 Contrast

- Primary body text should meet at least WCAG AA contrast against its surface.
- White text on green uses `green-500` or darker.
- Warning text uses a sufficiently dark orange/brown, not pale yellow.
- Disabled text remains readable but is clearly inactive.

### 15.2 Text Scaling

- Support system text scaling through at least `200%` without hiding essential actions.
- Segmented controls may become horizontally scrollable when labels no longer fit.
- Plant cards may grow vertically; fixed heights must not clip text.

### 15.3 Semantics

- Every icon-only button has a semantic label.
- A sensor metric is announced as a complete phrase, such as `pH enam koma dua, normal, target lima koma lima sampai enam koma lima`.
- Charts provide a textual summary for screen-reader users.
- Image semantics describe the plant, not decorative styling.

### 15.4 Touch and Focus

- Minimum target: `44 × 44 px`.
- Keyboard/focus traversal follows visual order.
- Focus states are visible.
- Do not place two small icon buttons immediately adjacent without spacing.

### 15.5 Non-Color Indicators

Every state uses at least:

- Color.
- Icon.
- Text label.

---

## 16. Content and Voice

### 16.1 Language

All MVP-facing application copy is Indonesian.

### 16.2 Tone

- Clear.
- Calm.
- Helpful.
- Direct.
- Non-judgmental.

### 16.3 Preferred Copy

| Avoid | Prefer |
|---|---|
| `Error!` | `Data belum dapat dimuat` |
| `Invalid pH` | `Data pH tidak tersedia` |
| `Device disconnected` | `Perangkat sedang offline` |
| `Danger` | `Kondisi kritis` |
| `No data` | `Data belum tersedia` |
| `Retry` | `Coba lagi` |
| `Save` | `Simpan` |

### 16.4 Measurement Formatting

- pH: one decimal by default, such as `6,2`.
- EC: one or two decimals depending on backend precision, such as `1,8 mS/cm`.
- TDS: whole ppm with Indonesian thousands formatting, such as `1.150 ppm`.
- Volume: one decimal when needed, such as `42,5 L`; whole liters when exact.
- Percentage: whole percent by default.
- Time uses the user's locale and 24-hour format for Indonesian MVP.
- Never append a unit twice.

---

## 17. Flutter Token Reference

The following structures define naming and expected values. The implementation may split them into focused files, but token names should remain stable.

### 17.1 Colors

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const green50 = Color(0xFFECF9F0);
  static const green100 = Color(0xFFD8F3E1);
  static const green200 = Color(0xFFB5E7C6);
  static const green300 = Color(0xFF7FD49B);
  static const green400 = Color(0xFF3DC469);
  static const green500 = Color(0xFF12B347);
  static const green600 = Color(0xFF0D963B);
  static const green700 = Color(0xFF087A32);
  static const green800 = Color(0xFF075F2A);
  static const green900 = Color(0xFF064921);

  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral25 = Color(0xFFFBFCFB);
  static const neutral50 = Color(0xFFF7F9F7);
  static const neutral100 = Color(0xFFF0F3F1);
  static const neutral200 = Color(0xFFE5EAE7);
  static const neutral300 = Color(0xFFD1D8D4);
  static const neutral400 = Color(0xFFA6AEA9);
  static const neutral500 = Color(0xFF747C77);
  static const neutral600 = Color(0xFF5D655F);
  static const neutral700 = Color(0xFF414843);
  static const neutral800 = Color(0xFF292F2B);
  static const neutral900 = Color(0xFF171B18);

  static const success = Color(0xFF159447);
  static const successSoft = Color(0xFFEAF7EF);
  static const warning = Color(0xFFD98200);
  static const warningSoft = Color(0xFFFFF4DD);
  static const critical = Color(0xFFC9363E);
  static const criticalSoft = Color(0xFFFDEBED);
  static const information = Color(0xFF2676C9);
  static const informationSoft = Color(0xFFEAF3FC);
  static const offline = Color(0xFF6F7772);
  static const offlineSoft = Color(0xFFEFF1F0);
  static const stale = Color(0xFFA26312);
  static const staleSoft = Color(0xFFFFF3E3);
}
```

### 17.2 Spacing and Radius

```dart
abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;
  static const huge = 48.0;
  static const massive = 64.0;
}

abstract final class AppRadius {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const xLarge = 24.0;
  static const full = 999.0;
}
```

### 17.3 Elevation

```dart
import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const low = <BoxShadow>[
    BoxShadow(
      color: Color(0x0D171B18),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static const medium = <BoxShadow>[
    BoxShadow(
      color: Color(0x17171B18),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const high = <BoxShadow>[
    BoxShadow(
      color: Color(0x24171B18),
      blurRadius: 40,
      offset: Offset(0, 18),
    ),
  ];
}
```

### 17.4 Typography

```dart
import 'dart:ui';

import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const fontFamily = 'Poppins';
  static const tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      height: 1.25,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      height: 1.29,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      height: 1.33,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      height: 1.4,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      height: 1.44,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 1.57,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      height: 1.5,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 1.43,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      height: 1.5,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      height: 1.45,
      fontWeight: FontWeight.w500,
    ),
  );

  static const sensorValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w600,
    fontFeatures: tabularFigures,
  );
}
```

### 17.5 ThemeData Baseline

```dart
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.green500,
      brightness: Brightness.light,
      primary: AppColors.green500,
      onPrimary: AppColors.neutral0,
      secondary: AppColors.green700,
      onSecondary: AppColors.neutral0,
      error: AppColors.critical,
      onError: AppColors.neutral0,
      surface: AppColors.neutral0,
      onSurface: AppColors.neutral900,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.neutral50,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.neutral700,
        displayColor: AppColors.neutral900,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.neutral50,
        foregroundColor: AppColors.neutral900,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.neutral0,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
          side: BorderSide(color: AppColors.neutral100),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          foregroundColor: AppColors.green700,
          side: const BorderSide(color: AppColors.neutral200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral0,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(
            color: AppColors.green500,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(
            color: AppColors.critical,
            width: 1.5,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.neutral0,
        indicatorColor: AppColors.green50,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.textTheme.labelMedium?.copyWith(
            color: selected
                ? AppColors.green700
                : AppColors.neutral500,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.green500
                : AppColors.neutral400,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral100,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
```

### 17.6 Status Mapping

```dart
enum SensorStatus {
  normal,
  warning,
  critical,
  stale,
  offline,
  incomplete,
  unavailable,
}

extension SensorStatusVisuals on SensorStatus {
  Color get foreground => switch (this) {
        SensorStatus.normal => AppColors.success,
        SensorStatus.warning => AppColors.warning,
        SensorStatus.critical => AppColors.critical,
        SensorStatus.stale => AppColors.stale,
        SensorStatus.offline => AppColors.offline,
        SensorStatus.incomplete => AppColors.information,
        SensorStatus.unavailable => AppColors.offline,
      };

  Color get background => switch (this) {
        SensorStatus.normal => AppColors.successSoft,
        SensorStatus.warning => AppColors.warningSoft,
        SensorStatus.critical => AppColors.criticalSoft,
        SensorStatus.stale => AppColors.staleSoft,
        SensorStatus.offline => AppColors.offlineSoft,
        SensorStatus.incomplete => AppColors.informationSoft,
        SensorStatus.unavailable => AppColors.offlineSoft,
      };

  String get label => switch (this) {
        SensorStatus.normal => 'Normal',
        SensorStatus.warning => 'Peringatan',
        SensorStatus.critical => 'Kritis',
        SensorStatus.stale => 'Data terlambat',
        SensorStatus.offline => 'Offline',
        SensorStatus.incomplete => 'Data tidak lengkap',
        SensorStatus.unavailable => 'Tidak tersedia',
      };
}
```

The frontend may map backend states to visual tokens, but it must not recalculate authoritative sensor safety states.

---

## 18. Component File Guidance

Recommended implementation boundaries:

```text
lib/
├── app/theme/
│   ├── app_colors.dart
│   ├── app_radius.dart
│   ├── app_shadows.dart
│   ├── app_spacing.dart
│   ├── app_theme.dart
│   └── app_typography.dart
├── core/widgets/
│   ├── app_async_view.dart
│   ├── app_empty_state.dart
│   ├── app_error_state.dart
│   ├── app_search_field.dart
│   ├── app_section_header.dart
│   ├── app_status_badge.dart
│   └── app_skeleton.dart
└── features/
    ├── dashboard/presentation/widgets/
    │   ├── device_status_indicator.dart
    │   ├── sensor_metric_item.dart
    │   ├── sensor_summary_card.dart
    │   └── volume_progress_indicator.dart
    ├── reports/presentation/widgets/
    │   ├── report_chart.dart
    │   ├── report_segmented_control.dart
    │   └── report_statistic_tile.dart
    ├── alerts/presentation/widgets/
    │   └── alert_list_item.dart
    ├── education/presentation/widgets/
    │   ├── plant_card.dart
    │   └── plant_parameter_card.dart
    └── profile/presentation/widgets/
        └── profile_menu_tile.dart
```

Do not build a single general-purpose card with many boolean parameters. Prefer small, focused components with clear responsibilities.

---

## 19. Quality and Testing Checklist

### Visual Regression

- Verify standard phone width around 360–430 logical pixels.
- Verify compact width around 320–359 logical pixels.
- Verify text scale at 100%, 150%, and 200%.
- Verify Android and iOS rendering.
- Verify light theme only; dark mode must not accidentally inherit unreadable colors.

### Component Tests

- Primary and secondary button states.
- Input validation, focus, error, and disabled states.
- Status badge mapping for all backend states.
- Sensor metric with value, unavailable value, stale timestamp, and partial failure.
- Bottom navigation contains exactly three destinations.
- Plant card handles one- and two-line names.
- Search empty result.
- Report chart empty state and threshold labels.
- Alert item ongoing and recovered state.

### Accessibility Tests

- Semantic labels on icon buttons.
- Complete semantic description for sensor readings.
- No status communicated through color alone.
- Tap targets meet the minimum size.
- Text scaling does not clip primary actions.
- Focus order matches visual order.

### Data Integrity Presentation

- Stale readings display age.
- Offline readings display last-contact time.
- Unavailable metrics show an em dash rather than zero.
- EC remains primary and TDS remains supporting data.
- Backend state labels are represented without local safety-state recalculation.

---

## 20. Do and Do Not

### Do

- Keep most surfaces white and use green purposefully.
- Prioritize current condition and freshness.
- Use rounded components consistently.
- Make plant imagery prominent on Education.
- Preserve clear status labels and timestamps.
- Use one report chart with switchable metrics.
- Keep the three-item bottom navigation stable.
- Support beginners with plain language and experts with precise values.

### Do Not

- Add category filters to Education.
- Add Reports as a bottom-navigation tab.
- Use a floating center action button.
- Fill every card with green.
- Use decorative gradients behind sensor data.
- Hide stale or offline timestamps.
- Use icon-only semantic status.
- Show unavailable readings as zero.
- Copy healthcare-specific layouts, imagery, doctor cards, chat flows, or branding from the reference.
- Add dark mode, automatic control, social features, or multi-tank switching to MVP.

---

## 21. Definition of Done

The design-system implementation is complete when:

- All documented tokens exist in Flutter and are used instead of repeated raw values.
- Authentication, Beranda, Education, Plant Detail, Reports, Alerts, and Profile follow the documented layout hierarchy.
- The application uses exactly three bottom-navigation destinations.
- The main sensor card communicates values, ranges, state, and freshness clearly.
- Every semantic state uses color, icon, and text.
- Education presents a searchable plant grid without filters.
- Component tests cover normal, warning, critical, stale, offline, incomplete, and unavailable states.
- The interface remains usable with large text and compact device widths.
- The final visual result reflects the clean, green, rounded, spacious character of the reference while remaining recognizably hydroponic and original.
