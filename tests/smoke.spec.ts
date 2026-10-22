import { test, expect } from '@playwright/test';

test('carga sin errores de consola', async ({ page }) => {
  const errores: string[] = [];
  page.on('console', (m) => {
    if (m.type() === 'error') errores.push(m.text());
  });
  page.on('pageerror', (e) => errores.push(e.message));
  await page.goto('/');
  await expect(page).toHaveTitle(/.+/);
  // El repo público no trae la URL de Supabase (config.local.js); ese error es esperado aquí.
  const inesperados = errores.filter((e) => !e.includes('Invalid supabaseUrl'));
  expect(inesperados).toEqual([]);
});

test('no hay scroll horizontal', async ({ page }) => {
  await page.goto('/');
  const sobra = await page.evaluate(
    () => document.documentElement.scrollWidth - document.documentElement.clientWidth,
  );
  expect(sobra).toBeLessThanOrEqual(0);
});
