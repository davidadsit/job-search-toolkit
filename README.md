# Job Search Toolkit

An AI-assisted job search system built with [Claude Code](https://claude.ai/claude-code). Generates customized resumes, cover letters, company research profiles, and interview prep for each application -- using your base career documents and a persistent Experience Bank that grows smarter over every application.

## How It Works

Your base documents (resume, cover letter, preferences) live in `Inputs/` and are never modified by skills. For each job application, Claude Code skills generate customized versions in `Applications/CompanyName/`. Archived applications are moved to `Archived/`.

## Setup

### 1. Install requirements

- [Claude Code](https://claude.ai/claude-code)
- [pandoc](https://pandoc.org/) with [weasyprint](https://weasyprint.org/) (for PDF generation)
- [Node.js](https://nodejs.org/) (for JavaScript-rendered job sites)

```bash
brew install pandoc poppler
pip install weasyprint pypdf
cd Scripts && npm install && npx playwright install chromium
```

### 2. Create your personal repo

This toolkit repo contains only the reusable skills and scripts. Your personal data (resume, cover letter, lead tracker, applications) belongs in a separate private repo.

Clone or fork this repo, then open Claude Code in the repo directory and run:

```
/get-started
```

This skill walks you through the full setup interactively -- collecting your contact info, preferences, resume, and cover letter, then writing all required `Inputs/` files and configuring the system files. When it finishes, you're ready to run your first job posting.

#### What `/get-started` sets up

```
Inputs/
  resume.md           # Your master resume
  cover-letter.md     # Your master cover letter
  preferences.md      # Your job search criteria
```

`Inputs/experience-bank.md` is created automatically by `/customize-for-job` the first time it uncovers undocumented experience.

`Inputs/ats-targets.md` is optional, copy it from `ats-targets.template.md` or let `/find-jobs` create it on first use. It grows automatically as company ATS platforms are discovered.

It also updates `.claude/skills/generate-pdfs/cover-letter-header.html` and `Scripts/generate-base-docs.sh` with your name and contact info.

#### One manual step after setup

In `.claude/skills/find-jobs/SKILL.md`, the regional VC job board list defaults to Utah-focused VCs. Replace these with VCs relevant to your metro area for better local leads.

## Skills

Run these from the Claude Code CLI with `/skill-name`:

### `/get-started`

Interactive onboarding for new users. Collects your contact info, job search preferences, resume, and cover letter through a guided conversation, then writes all required `Inputs/` files and configures the PDF generation system. Run this once when setting up the toolkit.

### `/find-jobs [keyword]`

Searches for engineering leadership roles (CTO, VP of Engineering, Head of Engineering) across multiple sources:

- LinkedIn Jobs, Wellfound, Y Combinator Work at a Startup, Built In, The Ladders, EngMgrJobs, Welcome to the Jungle
- Hacker News "Who is Hiring?" thread
- VC portfolio job boards (national and regional)

Ranks results against your profile in `preferences.md`, deduplicates against `lead-tracker.md`, and offers to add leads or start `/customize-for-job`.

Use `/find-jobs fintech` or any keyword to narrow results.

### `/customize-for-job [url-or-paste]`

Full application pipeline for a specific job:

1. Checks Lead Tracker for duplicates/closed leads
2. Researches the company (website, funding, leadership team)
3. Creates a structured company profile
4. Reads all base documents and the Experience Bank
5. Builds an ATS keyword inventory from the job description
6. Identifies qualification gaps and asks about undocumented experience
7. Generates a customized resume, cover letter, and interview talking points
8. Runs an ATS keyword verification pass
9. Updates the Lead Tracker

### `/compact-experience-bank`

Reorganizes the Experience Bank from job-specific Q&A entries into a topic-based format, merging redundancies and filling gaps through interactive questions. Run periodically to keep the Experience Bank clean and easy to search.

### `/archive-job FolderName`

Moves a job application folder from `Applications/` to `Archived/` and updates the Lead Tracker.

### `/generate-pdfs CompanyName`

Generates styled resume and cover letter PDFs from an application folder. Reports page counts and warns if the resume exceeds 2 pages or the cover letter spills to a second page.

## Pipeline Tracking

| File | Purpose |
|------|---------|
| `lead-tracker.md` | Full-funnel pipeline: Discovered > Researching > Applied > Interviewing > Offer > Closed |
| `closed-leads-archive.md` | Past closures; used by `/find-jobs` and `/customize-for-job` for deduplication |

## Output per Application

```
Applications/CompanyName/
  jd.md                                      # Saved job description with source URL
  company-profile.md           # Research: overview, funding, leadership, relevance
  resume.md      # Customized resume (markdown source)
  cover-letter.md  # Customized cover letter (markdown source)
  interview-talking-points.md  # Strengths, gap responses, questions to ask
  [Your Name] - Resume.pdf                   # Generated by /generate-pdfs
  [Your Name] - Cover Letter.pdf             # Generated by /generate-pdfs
```

## Experience Bank

`Inputs/experience-bank.md` accumulates knowledge across applications. When a gap analysis reveals undocumented experience, the answers are saved with tags for reuse in future applications. Run `/compact-experience-bank` periodically to reorganize entries by topic and merge redundancies.

## Scripts

| Script | Purpose |
|--------|---------|
| `Scripts/generate-base-docs.sh` | Regenerates generic resume and cover letter PDFs in `Documents/` from `Inputs/` markdown |
| `Scripts/generate-job-docs.sh <FolderName>` | Generates resume and cover letter PDFs for a specific application |
| `Scripts/fetch-rendered.mjs` | Renders JavaScript-heavy job pages via headless Playwright; used as a fallback by `/find-jobs` and `/customize-for-job` when WebFetch returns empty results |
| `Scripts/query-ats.mjs` | Queries Greenhouse/Ashby/Workable/Lever public APIs directly for a company's live job postings; used by `/find-jobs` Steps 2c/4.5 for zero-scraping freshness checks |
| `Scripts/sync-skills.sh [toolkit-path]` | Pulls shared skills from the toolkit into your personal repo |
| `Scripts/push-skills.sh [toolkit-path]` | Pushes shared skills and scripts from your personal repo back to the toolkit |

PDF generation scripts use pandoc with weasyprint and shared CSS from `.claude/skills/generate-pdfs/`.

`sync-skills.sh` and `push-skills.sh` resolve the toolkit path from (in order): the script argument, `JOB_SEARCH_TOOLKIT` env var, a `.toolkit-path` file at repo root, or a default relative path of `../../code/job-search-toolkit`.

## Requirements

- [Claude Code](https://claude.ai/claude-code)
- [pandoc](https://pandoc.org/) with [weasyprint](https://weasyprint.org/) and [pypdf](https://pypdf.readthedocs.io/)
- [Node.js](https://nodejs.org/) with [Playwright](https://playwright.dev/) (`cd Scripts && npm install && npx playwright install chromium`)

Page count reporting uses `pdfinfo` from [poppler](https://poppler.freedesktop.org/) (`brew install poppler` on macOS). `pypdf` strips pandoc/WeasyPrint metadata from generated PDFs to avoid ATS spam flags. Playwright is used by `fetch-rendered.mjs` to render JavaScript-heavy job pages that WebFetch cannot access.
