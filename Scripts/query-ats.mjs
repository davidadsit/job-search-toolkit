#!/usr/bin/env node
// Query public ATS JSON APIs directly, bypassing WebSearch/WebFetch scraping entirely.
// These endpoints are unauthenticated, unrendered JSON -- no JS execution, no bot-detection risk.
//
// Usage:
//   node query-ats.mjs --platform greenhouse --company medrio
//   node query-ats.mjs --targets Inputs/ats-targets.md
//   node query-ats.mjs --targets Inputs/ats-targets.md --title-keywords "VP,CTO,Head of Engineering,SVP"
//   node query-ats.mjs --platform ashby --company bankjoy --format json

const DEFAULT_KEYWORDS = ['VP', 'Vice President', 'CTO', 'Chief Technology Officer', 'Head of Engineering', 'SVP', 'Senior Vice President'];

function parseArgs(argv) {
  const args = { platform: null, company: null, targets: null, titleKeywords: DEFAULT_KEYWORDS, format: 'text' };
  const rest = argv.slice(2);
  for (let i = 0; i < rest.length; i++) {
    const a = rest[i];
    if (a === '--platform') args.platform = rest[++i];
    else if (a === '--company') args.company = rest[++i];
    else if (a === '--targets') args.targets = rest[++i];
    else if (a === '--title-keywords') args.titleKeywords = rest[++i].split(',').map((s) => s.trim());
    else if (a === '--format') args.format = rest[++i];
  }
  return args;
}

function usage() {
  process.stderr.write(
    'Usage: node query-ats.mjs --platform <greenhouse|ashby|workable|lever> --company <slug> [--title-keywords "a,b,c"] [--format text|json]\n' +
    '       node query-ats.mjs --targets <path-to-markdown-table> [--title-keywords "a,b,c"] [--format text|json]\n'
  );
}

async function fetchJSON(url) {
  const res = await fetch(url, { headers: { Accept: 'application/json' } });
  if (!res.ok) throw new Error(`HTTP ${res.status} for ${url}`);
  return res.json();
}

// Each fetcher returns a normalized array: { company, title, location, url, postedAt, platform }
const FETCHERS = {
  async greenhouse(company) {
    const data = await fetchJSON(`https://boards-api.greenhouse.io/v1/boards/${company}/jobs?content=false`);
    return (data.jobs || []).map((j) => ({
      company: j.company_name || company,
      title: j.title,
      location: j.location?.name || null,
      url: j.absolute_url,
      postedAt: j.first_published || j.updated_at || null,
      platform: 'greenhouse',
    }));
  },
  async ashby(company) {
    const data = await fetchJSON(`https://api.ashbyhq.com/posting-api/job-board/${company}`);
    return (data.jobs || []).map((j) => ({
      company,
      title: j.title,
      location: j.location || (j.isRemote ? 'Remote' : null),
      url: j.jobUrl || j.applyUrl,
      postedAt: j.publishedAt || null,
      platform: 'ashby',
    }));
  },
  async workable(company) {
    const data = await fetchJSON(`https://apply.workable.com/api/v1/widget/accounts/${company}`);
    return (data.jobs || []).map((j) => ({
      company: data.name || company,
      title: j.title,
      location: [j.city, j.state, j.country].filter(Boolean).join(', ') || (j.telecommuting ? 'Remote' : null),
      url: j.url || j.shortlink,
      postedAt: j.published_on || j.created_at || null,
      platform: 'workable',
    }));
  },
  async lever(company) {
    const data = await fetchJSON(`https://api.lever.co/v0/postings/${company}?mode=json`);
    return (Array.isArray(data) ? data : []).map((j) => ({
      company,
      title: j.text,
      location: j.categories?.location || null,
      url: j.hostedUrl,
      postedAt: j.createdAt ? new Date(j.createdAt).toISOString() : null,
      platform: 'lever',
    }));
  },
};

function escapeRegex(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// Unicode whitespace variants seen in real ATS job titles (rich-text-editor
// copy/paste artifacts): NBSP (00A0), en/em/thin/hair/figure spaces
// (2000-200A), narrow NBSP (202F), ideographic space (3000), zero-width space
// (200B), BOM/zero-width-no-break-space (FEFF). Literal string/regex matching
// against a normal keyword silently fails if the source title uses one of
// these instead of a plain space (U+0020) -- normalize both sides before
// comparing.
const UNICODE_WHITESPACE_RE = /[\u00a0\u2000-\u200b\u202f\u3000\ufeff]/g;

function normalizeWhitespace(s) {
  return s.replace(UNICODE_WHITESPACE_RE, ' ');
}

function matchesKeywords(title, keywords) {
  // Word-boundary matching, not naive substring: "Director" contains the literal
  // substring "cto" (dire-CTO-r), which would otherwise false-positive on every
  // "Director" title when matching the "CTO" keyword.
  const normalized = normalizeWhitespace(title);
  return keywords.some((k) => new RegExp(`\\b${escapeRegex(normalizeWhitespace(k))}\\b`, 'i').test(normalized));
}

function parseTargetsFile(text) {
  // Expects a markdown table with columns: Company | Platform | Slug | Notes (header row + separator row skipped)
  const targets = [];
  for (const line of text.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed.startsWith('|')) continue;
    const cells = trimmed.split('|').map((c) => c.trim()).filter((c) => c.length > 0);
    if (cells.length < 3) continue;
    const [company, platform, slug] = cells;
    if (platform.toLowerCase() === 'platform' || /^-+$/.test(platform)) continue; // header/separator rows
    if (!FETCHERS[platform.toLowerCase()]) continue; // skip unsupported/unconfirmed platforms (e.g. "?")
    targets.push({ company, platform: platform.toLowerCase(), slug });
  }
  return targets;
}

async function main() {
  const args = parseArgs(process.argv);
  if (!args.platform && !args.targets) {
    usage();
    process.exit(2);
  }

  let jobs = [];
  const errors = [];

  if (args.targets) {
    const fs = await import('node:fs/promises');
    const text = await fs.readFile(args.targets, 'utf8');
    const targets = parseTargetsFile(text);
    const results = await Promise.allSettled(
      targets.map((t) => FETCHERS[t.platform](t.slug))
    );
    results.forEach((r, i) => {
      if (r.status === 'fulfilled') jobs.push(...r.value);
      else errors.push(`${targets[i].company} (${targets[i].platform}/${targets[i].slug}): ${r.reason.message}`);
    });
  } else {
    const fetcher = FETCHERS[args.platform.toLowerCase()];
    if (!fetcher) {
      process.stderr.write(`Unknown platform: ${args.platform}. Supported: ${Object.keys(FETCHERS).join(', ')}\n`);
      process.exit(2);
    }
    try {
      jobs = await fetcher(args.company);
    } catch (err) {
      errors.push(`${args.company} (${args.platform}): ${err.message}`);
    }
  }

  const filtered = jobs.filter((j) => matchesKeywords(j.title, args.titleKeywords));

  if (args.format === 'json') {
    process.stdout.write(JSON.stringify({ jobs: filtered, errors }, null, 2) + '\n');
  } else {
    if (filtered.length === 0) {
      process.stdout.write('No matching postings found.\n');
    } else {
      for (const j of filtered) {
        process.stdout.write(`${j.company} -- ${j.title}\n  Location: ${j.location || 'unknown'}\n  Posted: ${j.postedAt || 'unknown'}\n  URL: ${j.url}\n  Platform: ${j.platform}\n\n`);
      }
    }
    if (errors.length > 0) {
      process.stderr.write(`\n${errors.length} target(s) failed:\n` + errors.map((e) => `  - ${e}`).join('\n') + '\n');
    }
  }
}

main().catch((err) => {
  process.stderr.write(`query-ats: ${err.message}\n`);
  process.exit(1);
});
