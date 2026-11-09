const { app, BrowserWindow, ipcMain, safeStorage, shell, dialog } = require('electron');
const fs = require('fs');
const path = require('path');

const HOSTED_APP_URL = 'https://swift-creation-app.lovable.app/dashboard';
const HOSTED_ORIGIN = new URL(HOSTED_APP_URL).origin;
let mainWindow;
let showingOfflinePage = false;
let loadAttempt = 0;
let blankScreenTimer;

const hasSingleInstanceLock = app.requestSingleInstanceLock();
if (!hasSingleInstanceLock) {
  app.quit();
} else {
  app.on('second-instance', () => {
    if (mainWindow) {
      if (mainWindow.isMinimized()) mainWindow.restore();
      mainWindow.focus();
    }
  });
}

const configPath = () => path.join(app.getPath('userData'), 'connection.json');
const tokenPath = () => path.join(app.getPath('userData'), 'session.bin');
function readConfig() { try { return JSON.parse(fs.readFileSync(configPath(), 'utf8')); } catch { return {}; } }
function writeConfig(config) { fs.writeFileSync(configPath(), JSON.stringify(config, null, 2), 'utf8'); }
function readSession() {
  try { const raw = fs.readFileSync(tokenPath()); return JSON.parse(safeStorage.isEncryptionAvailable() ? safeStorage.decryptString(raw) : raw.toString()); } catch { return null; }
}
function writeSession(session) {
  const value = Buffer.from(JSON.stringify(session));
  fs.writeFileSync(tokenPath(), safeStorage.isEncryptionAvailable() ? safeStorage.encryptString(value.toString()) : value);
}
function clearSession() { try { fs.unlinkSync(tokenPath()); } catch {} }

function isAllowedNavigation(rawUrl) {
  try {
    const url = new URL(rawUrl);
    return url.origin === HOSTED_ORIGIN || url.origin.endsWith('.supabase.co');
  } catch { return false; }
}

function showOfflinePage() {
  if (!mainWindow || mainWindow.isDestroyed() || showingOfflinePage) return;
  showingOfflinePage = true;
  if (blankScreenTimer) clearTimeout(blankScreenTimer);
  mainWindow.loadFile(path.join(__dirname, 'offline.html'));
}

function responsiveHostedLayer() {
  if (!mainWindow || mainWindow.isDestroyed()) return;
  mainWindow.webContents.insertCSS(`
    html { min-width: 0 !important; width: 100% !important; overflow-x: hidden !important; }
    body { min-width: 0 !important; max-width: 100vw !important; width: 100% !important; overflow-x: hidden !important; }
    *, *::before, *::after { box-sizing: border-box; }
    img, svg, video, canvas { max-width: 100%; }
    input, select, textarea, button { max-width: 100%; }
    #lovable-badge, [id*="lovable" i], [class*="lovable" i],
    a[href*="lovable.dev"], a[href*="lovable.app"] { display: none !important; visibility: hidden !important; }
    @media (max-width: 900px) {
      main, [role="main"] { min-width: 0 !important; max-width: 100vw !important; }
      header, nav, [role="banner"] { flex-wrap: wrap !important; }
    }
  `).catch(() => {});
  mainWindow.webContents.executeJavaScript(`(() => {
    const removeLovableBadge = () => document.querySelectorAll(
      '#lovable-badge, [id*="lovable" i], [class*="lovable" i], a[href*="lovable.dev"], a[href*="lovable.app"]'
    ).forEach(node => node.remove());
    removeLovableBadge();
    if (!window.__dexLovableBadgeObserver) {
      window.__dexLovableBadgeObserver = new MutationObserver(removeLovableBadge);
      window.__dexLovableBadgeObserver.observe(document.documentElement, { childList: true, subtree: true });
    }
  })()`).catch(() => {});
}

function loadHostedApp({ clearCache = false } = {}) {
  if (!mainWindow || mainWindow.isDestroyed()) return;
  showingOfflinePage = false;
  loadAttempt += 1;
  const attempt = loadAttempt;
  const load = () => mainWindow.loadURL(HOSTED_APP_URL, { extraHeaders: 'Cache-Control: no-cache\\n' });
  const proceed = clearCache
    ? mainWindow.webContents.session.clearCache().catch(() => {}).then(load)
    : Promise.resolve(load());
  proceed.catch(() => {});
  if (blankScreenTimer) clearTimeout(blankScreenTimer);
  blankScreenTimer = setTimeout(() => {
    if (attempt !== loadAttempt || !mainWindow || mainWindow.isDestroyed() || showingOfflinePage) return;
    if (loadAttempt < 3) loadHostedApp({ clearCache: true });
    else showOfflinePage();
  }, 15000);
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1440,
    height: 900,
    minWidth: 480,
    minHeight: 520,
    backgroundColor: '#07131f',
    autoHideMenuBar: true,
    title: 'DEX Admin Console',
    icon: path.join(__dirname, 'assets', 'dex-logo.ico'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true
    }
  });

  mainWindow.webContents.on('page-title-updated', (event) => {
    event.preventDefault();
    mainWindow.setTitle('DEX Admin Console');
  });
  mainWindow.webContents.on('will-navigate', (event, url) => {
    if (!isAllowedNavigation(url)) {
      event.preventDefault();
      shell.openExternal(url).catch(() => {});
    }
  });
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    if (!isAllowedNavigation(url)) shell.openExternal(url).catch(() => {});
    return { action: isAllowedNavigation(url) ? 'allow' : 'deny' };
  });
  mainWindow.webContents.on('console-message', (_event, level, message) => {
    if (level >= 2) console.warn(`[DEX hosted page] ${message}`);
  });
  mainWindow.webContents.on('did-fail-load', (_event, errorCode, _errorDescription, validatedURL) => {
    if (errorCode === -3) return;
    if (validatedURL.startsWith(HOSTED_ORIGIN)) {
      if (loadAttempt < 3) loadHostedApp({ clearCache: true });
      else showOfflinePage();
    }
  });
  mainWindow.webContents.on('did-finish-load', () => {
    showingOfflinePage = false;
    if (blankScreenTimer) clearTimeout(blankScreenTimer);
    loadAttempt = 0;
    responsiveHostedLayer();
    setTimeout(() => {
      if (!mainWindow || mainWindow.isDestroyed() || showingOfflinePage) return;
      mainWindow.webContents.executeJavaScript('Boolean(document.body && document.body.innerText.trim())').then(hasContent => {
        if (!hasContent) showOfflinePage();
      }).catch(() => {});
    }, 2500);
  });
  mainWindow.webContents.on('render-process-gone', () => {
    if (!showingOfflinePage) loadHostedApp({ clearCache: true });
  });
  loadHostedApp();
}

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => { if (!BrowserWindow.getAllWindows().length) createWindow(); });
});
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });

ipcMain.handle('connection:get', () => readConfig());
ipcMain.handle('connection:save', (_, config) => { writeConfig(config); return true; });
ipcMain.handle('session:get', () => readSession());
ipcMain.handle('session:save', (_, session) => { writeSession(session); return true; });
ipcMain.handle('session:clear', () => { clearSession(); return true; });
ipcMain.handle('app:reload-hosted', () => { loadHostedApp({ clearCache: true }); return true; });
ipcMain.handle('external:open', async (_, rawUrl) => {
  try {
    const url = new URL(String(rawUrl));
    if (!['https:'].includes(url.protocol)) return false;
    await shell.openExternal(url.toString());
    return true;
  } catch { return false; }
});
ipcMain.handle('pdf:save', async (event, options = {}) => {
  const html = String(options.html || '');
  if (!html || html.length > 4_000_000) throw new Error('The report is empty or too large to export.');
  const owner = BrowserWindow.fromWebContents(event.sender) || mainWindow;
  const result = await dialog.showSaveDialog(owner, {
    title: 'Save DEX commissions report',
    defaultPath: path.basename(String(options.fileName || 'DEX-Commissions.pdf')),
    filters: [{ name: 'PDF document', extensions: ['pdf'] }]
  });
  if (result.canceled || !result.filePath) return { canceled: true };
  const printWindow = new BrowserWindow({ show: false, webPreferences: { sandbox: true, contextIsolation: true, nodeIntegration: false } });
  try {
    await printWindow.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(html)}`);
    const pdf = await printWindow.webContents.printToPDF({ printBackground: true, pageSize: 'A4', margins: { top: 0.45, bottom: 0.45, left: 0.4, right: 0.4 } });
    fs.writeFileSync(result.filePath, pdf);
    return { canceled: false, filePath: result.filePath };
  } finally { if (!printWindow.isDestroyed()) printWindow.close(); }
});
