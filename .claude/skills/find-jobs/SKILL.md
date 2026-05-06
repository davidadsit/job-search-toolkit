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
- **`pipeline`:** Only check career pages of companies in `Company Pipeline.md`. Skip broad search.

## Target Profile

Read `Inputs/Preferences.md` for the full set of job search preferences including target roles, company criteria, compensation, location, excluded industries, and work environment requirements. Use the criteria there to filter and rank results.

Key filters to apply when searching (drawn from Preferences.md):
- Target titles (e.g., CTO, VP of Engineering, Head of Engineering)
- Company stage (e.g., Series A through Series C)
- Industry focus and exclusions
- Team size sweet spot
- Location and remote preferences
- Compensation minimum and target

## Web Request Strategy

Always prefer WebFetch over Playwright -- it is faster, cheaper, and runs silently.

- **Default:** Use WebFetch for all job board and career page requests.
- **Known JS-required sites:** Use Playwright directly (skip the WebFetch attempt) for sites confirmed to need JavaScript:
  - **linkedin.com** -- returns a login redirect without JavaScript
- **Fallback trigger:** If WebFetch returns a login redirect, an empty body, or fewer than ~200 characters of useful content, retry with Playwright (`browser_navigate` then `browser_snapshot`).
- **Playwright tooling:** `browser_navigate` to load the URL, `browser_snapshot` to extract structured page content. Fall back to `browser_take_screenshot` only if snapshot is insufficient.

## Process

### Step 1: Read existing data

1. Read `Company Pipeline.md` (if it exists) to get Active Target companies and their career page URLs.
2. Read `Lead Tracker.md` (if it exists) to identify leads already tracked (used for deduplication).

### Step 2: Search job boards

Run WebSearch queries across these sources. If a focus keyword was provided, append it to each query. Skip this step if the argument is `pipeline`.

1. **LinkedIn Jobs:** `"VP of Engineering" OR "Head of Engineering" OR "CTO" site:linkedin.com/jobs SaaS`
2. **Wellfound:** `"VP of Engineering" OR "CTO" site:wellfound.com`
3. **Y Combinator:** `"VP of Engineering" OR "CTO" site:workatastartup.com`
4. **Built In:** `CTO OR "VP Engineering" site:builtin.com SaaS`
5. **The Ladders:** `"VP of Engineering" OR "CTO" site:theladders.com SaaS`
6. **EngMgrJobs:** `"VP of Engineering" OR "CTO" site:engmgrjobs.com`
7. **Welcome to the Jungle:** `"VP of Engineering" OR "CTO" site:welcometothejungle.com`
8. **General web:** `"VP of Engineering" OR "CTO" SaaS startup "Series A" OR "Series B" OR "Series C"`
9. **Hacker News:** Search for the most recent "Ask HN: Who is hiring?" thread. If found, WebFetch the thread page and extract any comments mentioning your target titles at SaaS companies.

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

### Step 3: Check Company Pipeline

`Company Pipeline.md` may have two sections: **Active Targets** (companies actively being monitored for openings) and **Watching** (companies of lower priority to track over time).

**Active Targets:** For each company listed:
1. Run a WebSearch: `site:[career-page-domain] "engineering" OR "CTO" OR "VP"` (or WebFetch the career page URL directly if it looks like a static careers page)
2. Note any relevant openings found
3. Update the "Last Checked" date for that company in `Company Pipeline.md`

**Watching:** Do not run dedicated searches for Watching companies. If a Watching company happens to appear in the Step 2 job board results, flag it with a note that it's in the Watching list. No other action needed.

Skip this step if `Company Pipeline.md` does not exist or has no Active Targets.

### Step 4: Filter and deduplicate

1. Remove duplicate results (same company + same role title).
2. Remove any leads that already appear in `Lead Tracker.md`, including Closed Leads. Do not waste time researching or evaluating companies that have been previously discarded.
3. Discard results that are clearly not executive/leadership engineering roles (e.g., "CTO" in a company name but role is an IC position).
4. Flag but do not discard roles where stage, comp, or location are unknown.

### Step 5: Rank results

Score each result against the target profile in Preferences.md:

- **Strong Match (3):** Title + stage + industry + location all align, or comp data confirms fit
- **Good Match (2):** Most criteria align; one or two are unknown or slightly off
- **Worth Investigating (1):** Title matches but other criteria are unknown or partially misaligned

### Step 6: Present results

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

### Pipeline Company Check
- [CompanyName]: [Relevant opening found / No relevant openings / Career page not accessible]
```

If no results are found in a category, omit that section. If no results are found at all, say so honestly and suggest alternative approaches (networking, recruiters, adjusting search terms).

### Step 7: User interaction

1. Ask: "Which leads should I add to the Lead Tracker? (Enter numbers, 'all', or 'none')"
2. For selected leads, append them to the **Discovered** section of `Lead Tracker.md` (create the file from the template if it does not exist).
3. Update the **Pipeline Summary** counts in `Lead Tracker.md`.
4. Ask: "Want me to run `/customize-for-job` on any of these?"

## Important Rules

- NEVER fabricate job listings or company details. Only report what WebSearch actually returned.
- NEVER attempt authenticated access to LinkedIn or any other service.
- NEVER use em dashes in any output.
- Cap at ~20 WebSearch calls and ~10 WebFetch calls per run to stay responsive.
- Honestly note limitations: some job boards render client-side and may not appear in search results; postings may be stale or already filled.
- Include the posting date when available. Flag anything that appears older than 30 days.
- If a search query returns no relevant results, note it and move on. Do not pad results.
