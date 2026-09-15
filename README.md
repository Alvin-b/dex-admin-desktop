# DEX Admin Console

Windows desktop administration app for the same Supabase backend used by the Android client.

## Run and build

```powershell
npm install
npm approve-scripts electron
npm rebuild electron --cache .npm-cache
npm run start
npm run dist:win
```

The generated installer and portable executable are created in `release/`.

The app is intentionally built unsigned. Windows may show a SmartScreen prompt on first launch; choose **More info → Run anyway** only after confirming that the file was produced from this project.

If the Electron download is slow or times out, use an Electron mirror for the build:

```powershell
$env:ELECTRON_MIRROR = "https://npmmirror.com/mirrors/electron/"
npm rebuild electron --cache .npm-cache
npm run dist:win
```

## First launch

Enter the Supabase project URL and the **publishable/anon key** already used by the mobile client. Do not use a service-role key in a desktop application. Sign in with an active administrator account. The app then uses the authenticated JWT for protected API and REST calls.

## Included operations

- Live operational overview, revenue and payment queue
- Shipment search and status transitions
- Staff directory with activate/deactivate controls
- Commission approval and payment marking
- Payment notification review
- Broadcast announcement creation
- Audit log inspection and CSV export
