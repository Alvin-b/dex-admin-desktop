# DEX Admin Console

Windows desktop administration app for the same Supabase backend used by the mobile client. The current installer is a DEX-branded Electron shell around the live hosted console, so UI and backend-compatible route updates can be delivered at `https://swift-creation-app.lovable.app/dashboard` without downloading a new installer for every change.

## Run and build

```powershell
npm install
npm run start
npm run check
npm run dist:win:dir
```

The Windows x64 application directory is generated at `dist/win-unpacked/`. The executable is:

```text
 dist/win-unpacked/DEX Admin Console.exe
```

The project includes the DEX application icon at `assets/dex-logo.ico` and uses it for the Windows executable, installer, and shortcuts. The reproducible hosted-shell installer is `manual-installer-final-audit.nsi`; it builds the standalone `DEX-Admin-Console-Setup-1.2.1-full-functional-audit-x64.exe`. The installer detects a running app and offers to close it before replacing locked files. Do not commit `dist/` or `node_modules/` to GitHub.

The app is intentionally built unsigned. Windows may show a SmartScreen prompt on first launch; choose **More info → Run anyway** only after confirming that the file was produced from this project.

If the Electron download is slow or times out, use an Electron mirror:

```powershell
$env:ELECTRON_MIRROR = "https://npmmirror.com/mirrors/electron/"
npm rebuild electron
npm run dist:win:dir
```

## First launch

The hosted shell opens the Lovable dashboard URL above. Sign in with an active account; the hosted app uses the authenticated Supabase JWT for protected API and REST calls. The Electron wrapper keeps a branded offline fallback and opens non-console links in the system browser.

## Employee editing

The Staff screen sends profile edits to:

```text
PATCH /api/public/admin/employees
```

The profile-edit payload contains `employee_id`, `full_name`, `email`, `phone`, and `role`. The activation toggle uses a separate payload containing `employee_id` and `is_active`, matching the backend route contract.

## Included hosted operations

- Live operational overview, revenue and payment queue
- Shipment search and status transitions
- Staff directory with edit, activate/deactivate, and delete controls
- Commission approval and payment marking
- Payment notification review
- Broadcast announcement creation
- Audit log inspection and CSV export
- Administrator-only payment evidence correction, package unlinking, and audited deletion
- Employee email, role, phone, and optional password updates
- Searchable package tables, protected paid-cargo release, and per-staff commission filtering
