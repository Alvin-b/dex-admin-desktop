const { app, BrowserWindow, ipcMain, safeStorage, shell } = require('electron');
const fs = require('fs');
const path = require('path');

let mainWindow;
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
function createWindow() {
  mainWindow = new BrowserWindow({ width: 1440, height: 900, minWidth: 1100, minHeight: 700, backgroundColor: '#07131f', autoHideMenuBar: true, icon: path.join(__dirname, 'assets', 'dex-logo.ico'),
    webPreferences: { preload: path.join(__dirname, 'preload.js'), contextIsolation: true, nodeIntegration: false } });
  mainWindow.loadFile('index.html');
}
app.whenReady().then(() => { createWindow(); app.on('activate', () => { if (!BrowserWindow.getAllWindows().length) createWindow(); }); });
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
ipcMain.handle('connection:get', () => readConfig());
ipcMain.handle('connection:save', (_, config) => { writeConfig(config); return true; });
ipcMain.handle('session:get', () => readSession());
ipcMain.handle('session:save', (_, session) => { writeSession(session); return true; });
ipcMain.handle('session:clear', () => { clearSession(); return true; });
ipcMain.handle('external:open', async (_, rawUrl) => {
  try {
    const url = new URL(String(rawUrl));
    if (!['https:'].includes(url.protocol)) return false;
    await shell.openExternal(url.toString());
    return true;
  } catch { return false; }
});
