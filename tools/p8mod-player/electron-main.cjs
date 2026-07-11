const { app, BrowserWindow } = require('electron');

const url = process.argv.at(-1);
if (!url) throw new Error('PicoVibe player URL is required');

app.whenReady().then(() => {
  const window = new BrowserWindow({
    width: 720,
    height: 720,
    autoHideMenuBar: true,
    title: 'PicoVibe Preview',
  });
  window.loadURL(url);
  window.on('closed', () => app.quit());
});
