# ATS Targets

Curated list of companies mapped to their ATS platform, for direct API querying via `Scripts/query-ats.mjs`. This bypasses WebSearch/WebFetch scraping entirely, no JS rendering, no bot-detection risk, always-fresh data straight from the source.

**Supported platforms:** `greenhouse`, `ashby`, `workable`, `lever`. Rippling's ATS does not appear to expose an equivalent public endpoint; leave companies on Rippling out of this file or mark platform as `?` so the query script skips them.

**How to add a company:** Whenever `/find-jobs` or `/customize-for-job` discovers what ATS platform a company uses (visible in the job posting URL, e.g. `job-boards.greenhouse.io/{slug}`, `jobs.ashbyhq.com/{slug}`, `apply.workable.com` company page, or `jobs.lever.co/{slug}`), add a row here. The `slug` is the company identifier in that URL.

**Usage:**
```
node Scripts/query-ats.mjs --targets Inputs/ats-targets.md
node Scripts/query-ats.mjs --targets Inputs/ats-targets.md --title-keywords "VP,CTO,Head of Engineering,SVP"
```

| Company | Platform | Slug | Notes |
|---------|----------|------|-------|
