const { contextBridge, ipcRenderer } = require('electron');
contextBridge.exposeInMainWorld('dexAdmin', {
  getConnection: () => ipcRenderer.invoke('connection:get'),
  saveConnection: (value) => ipcRenderer.invoke('connection:save', value),
  getSession: () => ipcRenderer.invoke('session:get'),
  saveSession: (value) => ipcRenderer.invoke('session:save', value),
  clearSession: () => ipcRenderer.invoke('session:clear'),
  openExternal: (url) => ipcRenderer.invoke('external:open', url)
});
