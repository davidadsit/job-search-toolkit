#!/usr/bin/env node
import { chromium } from 'playwright';

function parseArgs(argv) {
  const args = { url: null, selector: null, timeout: 15000, format: 'text' };
  const rest = argv.slice(2);
  for (let i = 0; i < rest.length; i++) {
    const a = rest[i];
    if (a === '--selector') args.selector = rest[++i];
    else if (a === '--timeout') args.timeout = Number(rest[++i]);
    else if (a === '--format') args.format = rest[++i];
    else if (!args.url) args.url = a;
  }
  return args;
}

function usage() {
  process.stderr.write(
    'Usage: node fetch-rendered.mjs <url> [--selector <css>] [--timeout <ms>] [--format text|html]\n'
  );
}

const { url, selector, timeout, format } = parseArgs(process.argv);

if (!url) {
  usage();
  process.exit(2);
}
if (format !== 'text' && format !== 'html') {
  process.stderr.write(`Invalid --format: ${format} (expected "text" or "html")\n`);
  process.exit(2);
}

const browser = await chromium.launch({ headless: true });
let exitCode = 0;
try {
  const context = await browser.newContext();
  await context.route('**/*', (route) => {
    const t = route.request().resourceType();
    if (t === 'image' || t === 'font' || t === 'media') return route.abort();
    return route.continue();
  });
  const page = await context.newPage();

  if (selector) {
    await page.goto(url, { timeout });
    await page.waitForSelector(selector, { timeout });
  } else {
    await page.goto(url, { waitUntil: 'networkidle', timeout });
  }

  const out =
    format === 'html'
      ? await page.content()
      : await page.evaluate(() => document.body.innerText);
  process.stdout.write(out);
} catch (err) {
  process.stderr.write(`fetch-rendered: ${err.message}\n`);
  exitCode = 1;
} finally {
  await browser.close();
  process.exit(exitCode);
}
