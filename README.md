# DEX Admin Console

Windows desktop administration app for the same Supabase backend used by the Android client.

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

The project includes the DEX application icon at `assets/dex-logo.ico` and uses it for the Windows executable build. The complete application directory can be zipped for distribution; do not commit `dist/` or `node_modules/` to GitHub.

The app is intentionally built unsigned. Windows may show a SmartScreen prompt on first launch; choose **More info → Run anyway** only after confirming that the file was produced from this project.

If the Electron download is slow or times out, use an Electron mirror:

```powershell
$env:ELECTRON_MIRROR = "https://npmmirror.com/mirrors/electron/"
npm rebuild electron
npm run dist:win:dir
```

## First launch

Enter the Supabase project URL and the **publishable/anon key** already used by the mobile client. Do not use a service-role key in a desktop application. Sign in with an active administrator account. The app then uses the authenticated JWT for protected API and REST calls.

## Employee editing

The Staff screen sends profile edits to:

```text
PATCH /api/public/admin/employees
```

The profile-edit payload contains `employee_id`, `full_name`, `email`, `phone`, and `role`. The activation toggle uses a separate payload containing `employee_id` and `is_active`, matching the backend route contract.

## Included operations

- Live operational overview, revenue and payment queue
- Shipment search and status transitions
- Staff directory with edit, activate/deactivate, and delete controls
- Commission approval and payment marking
- Payment notification review
- Broadcast announcement creation
- Audit log inspection and CSV export
