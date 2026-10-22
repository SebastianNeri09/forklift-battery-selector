import { defineConfig, devices } from '@playwright/test';

const PORT = 4173;

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  reporter: 'list',
  use: { baseURL: `http://127.0.0.1:${PORT}` },
  webServer: {
    command: `python -m http.server ${PORT} --bind 127.0.0.1 --directory web`,
    url: `http://127.0.0.1:${PORT}`,
    reuseExistingServer: true,
  },
  projects: [
    { name: 'escritorio', use: { ...devices['Desktop Chrome'] } },
    { name: 'movil', use: { ...devices['Pixel 7'] } },
  ],
});
