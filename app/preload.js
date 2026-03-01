const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  selectFolder: () => ipcRenderer.invoke('select-folder'),
  startScan: (type, folder) => ipcRenderer.invoke('start-scan', { type, folder }),
  getLogs: () => ipcRenderer.invoke('get-logs'),
  getQuarantine: () => ipcRenderer.invoke('get-quarantine'),
  onScanOutput: (cb) => ipcRenderer.on('scan-output', (_, data) => cb(data)),
  offScanOutput: () => ipcRenderer.removeAllListeners('scan-output'),
  windowMinimize: () => ipcRenderer.send('window-minimize'),
  windowMaximize: () => ipcRenderer.send('window-maximize'),
  windowClose: () => ipcRenderer.send('window-close'),
});
