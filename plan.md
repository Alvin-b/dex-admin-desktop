# DEX Admin Desktop responsive rebuild

## Goal
Create a dependable Electron desktop shell that loads the hosted DEX dashboard, so changes deployed to the hosted app appear automatically in installed desktop clients. The shell should preserve the hosted app's navigation and provide a graceful offline page when the hosted service is unreachable.

## Implementation approach
- Load `https://swift-creation-app.lovable.app/dashboard` from Electron instead of bundling a second UI copy.
- Keep navigation restricted to the hosted dashboard and the required Supabase origin.
- Keep the wrapper's offline fallback so a temporary network outage is explicit and recoverable.
- Keep the window sizing improvements, while implementing the actual responsive layout and refresh behavior in the hosted dashboard source.

## Design direction
- **Style options:** Quiet operations cockpit (0.07); Compact dispatch console (0.05); Calm logistics workspace (0.08).
- **Chosen movement:** Quiet operations cockpit.
- **Core principles:** high signal-to-noise, stable controls, readable data density, and graceful degradation.
- **Color philosophy:** retain the dark navy DEX identity, using blue/teal for healthy system states and amber/red only for action or partial-failure states.
- **Layout paradigm:** a persistent workspace rail on wide screens that collapses to a compact top navigation on narrow screens, with content cards that reflow rather than shrink below readable widths. This is implemented in the hosted dashboard, not duplicated in Electron.
- **Signature elements:** sticky action header, scroll-contained data tables, and explicit sync-status messaging.
- **Interaction philosophy:** actions remain reachable and never depend on precise viewport dimensions; refresh feedback is visible and reversible.
- **Typography:** existing Manrope body with DM Mono for operational labels and metrics.
- **Brand voice:** concise and operational. Example: “Some sources need attention; your last good records are still available.”

## Project structure
- `main.js`: Electron lifecycle, local renderer loading, window constraints and native integrations.
- `renderer.js`, `styles.css`, and `index.html`: retained as repository-local development artifacts, but not used as the installed desktop UI while hosted mode is enabled.
- `plan.md` and `TODO.md`: implementation record.

## Required behavior
- The app must load the hosted dashboard as its primary desktop UI.
- Hosted refresh failures must be fixed in the hosted dashboard source so all clients receive the same behavior.
- The hosted dashboard must remain usable at narrow widths without squeezed text or accidental page-wide overflow.
