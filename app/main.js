const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const fs = require('fs');

let mainWindow;
let SCRIPT_DIR;

function createWindow() {
  SCRIPT_DIR = path.resolve(process.cwd(), '..');
  console.log('SCRIPT_DIR:', SCRIPT_DIR);

  mainWindow = new BrowserWindow({
    width: 1100,
    height: 750,
    minWidth: 900,
    minHeight: 600,
    frame: false,
    titleBarStyle: 'hidden',
    backgroundColor: '#0a0e1a',
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  });

  mainWindow.loadFile(path.join(__dirname, 'index.html'));
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

// ── Sélection de dossier ──────────────────────────────────────
ipcMain.handle('select-folder', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openDirectory'],
    title: 'Choisir le dossier à analyser'
  });
  if (!result.canceled && result.filePaths.length > 0) {
    return result.filePaths[0];
  }
  return null;
});

// ── Lancement du scan ─────────────────────────────────────────
ipcMain.handle('start-scan', async (event, { type, folder }) => {
  return new Promise((resolve) => {
    const mainScript = path.resolve(SCRIPT_DIR, 'main.sh');
    console.log('Lancement:', mainScript, type, folder);

    const proc = spawn('bash', [mainScript, type, folder], {
      cwd: SCRIPT_DIR,
      env: { ...process.env, SCRIPT_DIR }
    });

    let output = '';
    let errorOutput = '';

    proc.stdout.on('data', (data) => {
      const chunk = data.toString();
      output += chunk;
      mainWindow.webContents.send('scan-output', chunk);
    });

    proc.stderr.on('data', (data) => {
      const chunk = data.toString();
      errorOutput += chunk;
      mainWindow.webContents.send('scan-output', '[ERR] ' + chunk);
    });

    proc.on('close', (code) => {
      resolve({ code, output, errorOutput });
    });
  });
});

// ── Lire les logs ─────────────────────────────────────────────
ipcMain.handle('get-logs', async () => {
  const logDir = path.join(SCRIPT_DIR, 'logs');
  try {
    const files = fs.readdirSync(logDir)
      .filter(f => f.endsWith('.log'))
      .sort()
      .reverse()
      .slice(0, 10);
    return files.map(f => ({
      name: f,
      content: fs.readFileSync(path.join(logDir, f), 'utf8'),
      date: fs.statSync(path.join(logDir, f)).mtime
    }));
  } catch {
    return [];
  }
});

// ── Lire la quarantaine ───────────────────────────────────────
ipcMain.handle('get-quarantine', async () => {
  const qDir = path.join(SCRIPT_DIR, 'quarantine');
  try {
    if (!fs.existsSync(qDir)) return [];
    return fs.readdirSync(qDir).map(f => {
      const stat = fs.statSync(path.join(qDir, f));
      return { name: f, size: stat.size, date: stat.mtime };
    });
  } catch {
    return [];
  }
});

// ── Contrôles fenêtre ─────────────────────────────────────────
ipcMain.on('window-minimize', () => mainWindow.minimize());
ipcMain.on('window-maximize', () => {
  if (mainWindow.isMaximized()) mainWindow.unmaximize();
  else mainWindow.maximize();
});
ipcMain.on('window-close', () => app.quit());
