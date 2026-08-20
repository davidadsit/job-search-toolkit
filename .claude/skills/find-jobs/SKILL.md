---
name: find-jobs
description: Search multiple job sources for engineering leadership roles matching target profile
argument-hint: [optional-focus-keyword-or-pipeline]
---

Search multiple web sources for engineering leadership roles and present ranked results.

## Input

The argument is optional:

- **No argument:** Full broad search across all sources.
- **A keyword or phrase** (e.g., `fintech`, `remote`, `healthcare`): Appended to each search query to narrow results.

## Target Profile

Read `Inputs/preferences.md` for the full set of job search preferences including target roles, company criteria, compensation, location, excluded industries, and work environment requirements. Use the criteria there to filter and rank results.

Key filters to apply when searching (drawn from Preferences.md):
- Target titles (e.g., CTO, VP of Engineering, Head of Engineering)
- Company stage (e.g., Series A through Series C)
- Industry focus and exclusions
- Team size sweet spot
- Location and remote preferences
- Compensation minimum and target

## Web Request Strategy

Always prefer WebFetch over the Playwright CLI -- it is faster, cheaper, and runs silently.

- **Default:** Use WebFetch for all job board and career page requests.
- **Known JS-required sites:** Use the Playwright CLI directly (skip the WebFetch attempt) for sites confirmed to need JavaScript:
  - **linkedin.com** -- returns a login redirect without JavaScript
- **Fallback trigger:** If WebFetch returns a login redirect, an empty body, or fewer than ~200 characters of useful content, retry with the CLI.
- **CLI invocation:** `node Scripts/fetch-rendered.mjs "<url>"` returns rendered text on stdout. Add `--selector "<css>"` to wait for a specific element, or `--format html` if structure matters. Each call is one-shot and parallel-safe -- batch independent URLs in a single message.

## Process

### Step 1: Read existing data

Read `lead-tracker.md` (if it exists) to identify leads already tracked. Also read `closed-leads-archive.md` (if it exists) for past closures. Both are used for deduplication.

### Step 2: Search job boards

Run WebSearch queries across these sources. If a focus keyword was provided, append it to each query.

1. **LinkedIn Jobs:** `"VP of Engineering" OR "Head of Engineering" OR "CTO" site:linkedin.com/jobs SaaS`
2. **Wellfound:** `"VP of Engineering" OR "CTO" site:wellfound.com`
3. **Y Combinator:** `"VP of Engineering" OR "CTO" site:workatastartup.com`
4. **Built In:** `CTO OR "VP Engineering" site:builtin.com SaaS`
5. **The Ladders:** `"VP of Engineering" OR "CTO" site:theladders.com SaaS`
6. **EngMgrJobs:** `"VP of Engineering" OR "CTO" site:engmgrjobs.com`
7. **Welcome to the Jungle:** `"VP of Engineering" OR "CTO" site:welcometothejungle.com`
8. **General web:** `"VP of Engineering" OR "CTO" SaaS startup "Series A" OR "Series B" OR "Series C"`
9. **Hacker News:** Search for the most recent "Ask HN: Who is hiring?" thread. If found, WebFetch the thread page and extract any comments mentioning your target titles at SaaS companies.
10. **Silicon Slopes (regional):** WebFetch `https://jobs.siliconslopes.com/jobs/` and scan for target titles. Utah's tech community job board; update to your own region's equivalent community job board if not Utah-based.
11. **Himalayas:** `"VP of Engineering" OR "CTO" site:himalayas.app` or WebFetch `https://himalayas.app/jobs/cto` and `https://himalayas.app/jobs/vp-of-engineering` directly. Remote-focused board; apply the usual industry exclusion filters, it surfaces some crypto/blockchain listings.
12. **Recruiting from Scratch:** WebFetch `https://www.recruitingfromscratch.com/roles/cto`, `https://www.recruitingfromscratch.com/roles/vp-of-engineering`, and `https://www.recruitingfromscratch.com/roles/svp-of-engineering`. Technical recruiting firm with dedicated public listings for these titles at VC-backed startups.

### Step 2b: Search VC portfolio job boards

Search for roles across VC portfolio job boards. These often surface roles at Series A-C companies that never appear on mainstream job boards.

For each VC job board below, run a WebFetch or WebSearch to find relevant openings. Given the WebSearch/WebFetch budget, pick 6-8 of these per run, rotating across runs to cover them all over time.

**Regional VCs (update these to match your location):**

The examples below are Utah-focused; replace with VCs relevant to your metro area.

| VC Firm | Job Board URL | Focus |
|---------|--------------|-------|
| Pelion Venture Partners | https://jobs.pelionvp.com/jobs | Seed/Series A B2B software, SLC-based |
| Kickstart Fund | https://jobs.kickstart.com/jobs | Pre-seed/seed, Mountain West |
| Peterson Ventures | https://jobs.petersonventures.com | Early-stage digital commerce + SaaS, SLC-based |
| Album VC | https://jobs.albumvc.com/jobs (or WebSearch `site:albumvc.com` if no board found) | Seed/Series A, Lehi UT-based (Podium, Filevine, Divvy in portfolio) |
| Sorenson Capital | https://www.sorensoncapital.com/portfolio (WebSearch `"CTO" OR "VP of Engineering" site:sorensoncapital.com` for linked postings) | Early/growth-stage B2B software, cybersecurity, DevOps, Lehi UT-based |

**National VCs:**

| VC Firm | Job Board URL |
|---------|--------------|
| Andreessen Horowitz (a16z) | https://jobs.a16z.com/jobs |
| Sequoia Capital | https://jobs.sequoiacap.com/companies |
| Accel | https://jobs.accel.com/jobs |
| Greylock Partners | https://jobs.greylock.com/jobs |
| Bessemer Venture Partners | https://jobs.bvp.com/jobs |
| Sapphire Ventures | https://jobs.sapphireventures.com/jobs |
| Insight Partners | https://jobs.insightpartners.com/ |

**How to search VC job boards:**
- For boards with search/filter capability: WebFetch the job board URL with a prompt asking to extract relevant roles at SaaS companies.
- For boards without search: WebFetch the jobs page and scan for relevant titles.
- For VCs with only a portfolio page (no job board): WebSearch `"CTO" OR "VP of Engineering" site:[vc-domain]` to find any linked job postings.
- Note the source VC for each result so you know the company's investor backing.
- **"Consider" platform boards (a16z, Accel, Bessemer, Sapphire, Pelion, and others use this vendor):** These boards actively block headless/non-browser traffic, both WebFetch and the Playwright CLI (`fetch-rendered.mjs`) typically fail (empty shell content, or the CLI errors with "Download is starting"). Do not spend WebFetch/CLI budget retrying the board URL directly. Instead go straight to the site-scoped WebSearch fallback (`"VP of Engineering" OR "CTO" site:jobs.[vc-domain]`), which reaches Google's index of individual job postings even though the board itself won't render.

### Step 2c: Query ATS platforms directly

Several major applicant tracking systems expose free, unauthenticated JSON APIs per company, no JS rendering, no bot-detection risk, and always current since it queries the live source. This is strictly better than WebSearch/WebFetch for any company hosted on one of these platforms, which covers a large share of Series A-C startups (confirmed working: Greenhouse, Ashby, Workable, Lever; Rippling's ATS does not appear to have an equivalent).

If `Inputs/ats-targets.md` doesn't exist yet, copy it from `Inputs/ats-targets.template.md` first (or create it fresh with the same header row), the query script errors on a missing targets file.

Run:
```
node Scripts/query-ats.mjs --targets Inputs/ats-targets.md --title-keywords "VP,CTO,Head of Engineering,SVP,Vice President,Senior Vice President"
```

This queries every company in `Inputs/ats-targets.md` in parallel and returns only postings whose title matches one of the keywords (word-boundary matched, not naive substring, so it won't false-positive on things like "Director" containing "cto").

**Adding new companies to the target list:** Whenever a job posting URL from Step 2, 2b, or company research (`/customize-for-job`) reveals its ATS, the URL pattern gives away the platform:
- Greenhouse: `job-boards.greenhouse.io/{slug}` or `boards.greenhouse.io/{slug}`
- Ashby: `jobs.ashbyhq.com/{slug}`
- Workable: `apply.workable.com` (company name is in the page, not always the URL, check the page title or use `--platform workable --company {guess}` to test)
- Lever: `jobs.lever.co/{slug}`

Add a row to `Inputs/ats-targets.md` with the company name, platform, slug, and a short note. This makes the target list grow organically over time, every company researched anywhere in this toolkit becomes a permanent, zero-cost freshness-check source for future runs. Companies that close, get acquired, or turn out to be a poor fit can stay in the list (their notes are useful context), Step 3's dedup against `lead-tracker.md` / `closed-leads-archive.md` handles filtering them back out if they resurface.

**For a single company (e.g., verifying a lead found elsewhere is still live):**
```
node Scripts/query-ats.mjs --platform greenhouse --company medrio
node Scripts/query-ats.mjs --platform ashby --company bankjoy --title-keywords "VP,Engineering"
```

### Step 3: Filter and deduplicate

1. Remove duplicate results (same company + same role title).
2. Remove any leads that already appear in `lead-tracker.md` or `closed-leads-archive.md` (past closures). Do not waste time researching or evaluating companies that have been previously discarded.
3. Discard results that are clearly not executive/leadership engineering roles (e.g., "CTO" in a company name but role is an IC position).
4. Flag but do not discard roles where stage, comp, or location are unknown.

### Step 4: Rank results

Score each result against the target profile in Preferences.md:

- **Strong Match (3):** Title + stage + industry + location all align, or comp data confirms fit
- **Good Match (2):** Most criteria align; one or two are unknown or slightly off
- **Worth Investigating (1):** Title matches but other criteria are unknown or partially misaligned

### Step 4.5: Verify freshness of shortlisted results

Job board search results are frequently stale, postings get filled, pulled, or the company gets acquired, often well before a search engine's index catches up. Presenting dead leads wastes the user's evaluation time, so verify before presenting rather than after.

Only check the results that survived Step 3/4 and would actually be shown to the user (typically 5-15 results), not every raw search hit. For each shortlisted result:

1. **If the company is in `Inputs/ats-targets.md` (or its posting URL matches one of the ATS patterns from Step 2c):** re-query that single company's ATS API directly (`node Scripts/query-ats.mjs --platform {platform} --company {slug}`) rather than WebFetching the posting page. It's faster, cheaper, and definitive, if the job ID isn't in the response, it's closed. Add the company to `ats-targets.md` if it wasn't already there.
2. **Otherwise:** WebFetch the direct posting URL (falling back to the Playwright CLI per the Web Request Strategy rules above if needed) and look for closure signals: "no longer accepting applications," "position filled," "job not found," "no longer open," "removed on [date]," an expired-listing notice, or a redirect to a generic careers/search page instead of the specific posting.
3. If a quick company-name + role-title WebSearch surfaces an acquisition, shutdown, or leadership-change announcement that would make the posting moot (e.g., the company was acquired since the listing was indexed), treat it as closed even if the posting page itself still loads.
4. **If closed or clearly stale:** drop it from the results presented to the user. Do not spend further evaluation effort on it. If it's dropped after already digging into details worth remembering (comp, reporting line, culture signals), note it briefly so the user isn't left wondering why it disappeared.
5. **If freshness can't be determined either way:** keep it in the results but flag "posting freshness unconfirmed" in its notes.
6. This adds roughly one extra WebFetch/WebSearch/ATS-query per shortlisted result, on top of the discovery-phase budget. It draws from the same ~20 WebSearch / ~10 WebFetch cap (ATS API queries are cheap and don't count against it meaningfully), so keep the shortlist reasonably sized rather than freshness-checking everything found.

### Step 5: Present results

Display results grouped by rank:

```
### Strong Matches

1. **[Role Title]** at [CompanyName] ([Stage], $[Funding] raised)
   - Source: [Site] | Posted: [Date if known]
   - URL: [link]
   - Signals: [SaaS, remote, team size, comp range, etc.]

### Good Matches
...

### Worth Investigating
...
```

If no results are found in a category, omit that section. If no results are found at all, say so honestly and suggest alternative approaches (networking, recruiters, adjusting search terms).

### Step 6: User interaction

1. Ask: "Which leads should I add to the Lead Tracker? (Enter numbers, 'all', or 'none')"
2. For selected leads, append them to the **Discovered** section of `lead-tracker.md` (create the file from the template if it does not exist).
3. Update the **Pipeline Summary** counts in `lead-tracker.md`.
4. Ask: "Want me to run `/customize-for-job` on any of these?"

## Important Rules

- NEVER fabricate job listings or company details. Only report what WebSearch actually returned.
- NEVER attempt authenticated access to LinkedIn or any other service.
- NEVER use em dashes in any output.
- Cap at ~20 WebSearch calls and ~10 WebFetch calls per run to stay responsive.
- Honestly note limitations: some job boards render client-side and may not appear in search results. Shortlisted results should go through the Step 4.5 freshness check rather than being presented with an unverified "may be stale" caveat; if freshness genuinely could not be determined after attempting the check, say so explicitly for that specific result.
- Include the posting date when available. Flag anything that appears older than 30 days.
- If a search query returns no relevant results, note it and move on. Do not pad results.
