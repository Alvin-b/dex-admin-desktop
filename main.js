const { app, BrowserWindow, ipcMain, safeStorage, shell, dialog } = require('electron');
const fs = require('fs');
const path = require('path');

const HOSTED_APP_URL = 'https://swift-creation-app.lovable.app/dashboard';
const HOSTED_ORIGIN = new URL(HOSTED_APP_URL).origin;
let mainWindow;
let showingOfflinePage = false;

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
  mainWindow.loadFile(path.join(__dirname, 'offline.html'));
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1440,
    height: 900,
    minWidth: 760,
    minHeight: 560,
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
  mainWindow.webContents.on('did-fail-load', (_event, errorCode, _errorDescription, validatedURL) => {
    if (errorCode !== -3 && validatedURL.startsWith(HOSTED_ORIGIN)) showOfflinePage();
  });
  mainWindow.webContents.on('did-finish-load', () => { showingOfflinePage = false; });
  mainWindow.loadURL(HOSTED_APP_URL);
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
ipcMain.handle('app:reload-hosted', () => { showingOfflinePage = false; mainWindow?.loadURL(HOSTED_APP_URL); return true; });
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
