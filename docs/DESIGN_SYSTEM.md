# Design System — Light Mode MVP

## Reference hierarchy
Dedicated mockups for Home, Food Check, Atur, Login/Register, and Settings are the primary visual references. The brand overview image is secondary. If two references conflict, report the conflict instead of silently choosing a new design. Chat mockups are reference-only and must not be implemented in MVP.

## Brand palette starting point
- Electric Teal `#00F0A8`
- Deep Midnight Navy `#081426`
- Sunset Orange `#FF5A36`
- Buttermilk `#FFF4D0`
- Off White `#FAF8F5`
- White `#FFFFFF`

Use navy/dark text for readable text. Do not use bright teal for small text on white unless measured contrast passes. Orange is caution/attention, not generic success. Food status always includes text/icon; color alone is insufficient. Adjust derived tokens only with documented contrast/accessibility rationale.

## Typography and layout
- Font: Plus Jakarta Sans if the font files/license and project setup support it; otherwise use a clean system fallback and document the decision.
- 4/8-point spacing scale: 4, 8, 12, 16, 24, 32, 40, 48.
- Mobile horizontal padding ~16; card padding ~16; section spacing ~24.
- Card radius ~16; input/button radius ~12.
- Target 48×48 logical pixels for primary touch targets where feasible.
- Body text typically 14–16sp or larger; support OS text scaling.
- Use safe areas, keyboard insets, scrollable layouts and responsive constraints.

## Component principles
Use ThemeData and centralized tokens; avoid scattered hardcoded colors. Reusable button, field, card, status badge, loading, error, empty and permission states should have defined behavior. One clear primary action per screen. No dead buttons, excessive nested cards, unnecessary glow, or screenshot-as-UI. Animations must be subtle and functional.

## Scope
Light Mode only in MVP. Theme tokens must make future Dark Mode possible, but do not implement Dark Mode now. No web-specific breakpoint work until Android is stable.
