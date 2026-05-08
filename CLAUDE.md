# CLAUDE.md

Project-level instructions for Claude Code. These apply to every skill and session in this repo.

## Hard Rules for All Output

- **Never use em dashes** (-- or —) in any document that will be sent to an employer. Use a comma, colon, semicolon, or a new sentence instead.
- **Never modify files in `Inputs/`.** They are the source of truth for base documents. Skills read from them and write customized output to `Applications/CompanyName/`.
- **Never fabricate job listings, company facts, or experience.** Only report what sources actually returned.

## File Naming Conventions

Internal working files use hyphenated lowercase:
- `lead-tracker.md`, `closed-leads-archive.md`
- `Inputs/resume.md`, `Inputs/cover-letter.md`, `Inputs/experience-bank.md`, `Inputs/preferences.md`
- Per-application source files: `resume.md`, `cover-letter.md`, `company-profile.md`, `jd.md`, `interview-talking-points.md`

Recruiter-facing PDF outputs use human-friendly names with spaces:
- `[Your Name] - Resume.pdf`, `[Your Name] - Cover Letter.pdf`

## Skill Ownership

**Shared with toolkit** (sync via `Scripts/push-skills.sh` / `Scripts/sync-skills.sh`):
- archive-job, compact-experience-bank, customize-for-job, find-jobs, generate-pdfs

Private skills (personal workflow tools like pipeline reports, follow-ups, outreach) stay in your personal repo and are not pushed to the toolkit.
