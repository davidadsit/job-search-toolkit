Walk a brand-new user through initial toolkit setup, from zero to ready-to-run their first job posting. By the end, all required `Inputs/` files exist, system configuration files contain real data, and the user knows exactly what to run next.

Work through the phases in order. Never skip ahead. Never write a file without first showing a complete draft and receiving explicit approval.

---

## Before Starting: Read the Templates

Before collecting any information, read both template files to understand the exact format expected:

1. Read `Inputs/Preferences.template.md`
2. Read `Inputs/Resume.template.md`

These are the authoritative format references. Every file you write must match these structures exactly.

---

## Phase 0: Check Current State

Check which setup tasks are already complete:

1. Does `Inputs/Preferences.md` exist?
2. Does `Inputs/Resume.md` exist?
3. Does `Inputs/Cover Letter.md` exist?
4. Does `.claude/skills/generate-pdfs/cover-letter-header.html` still contain the placeholder text "YOUR NAME"?
5. Does `Scripts/generate-base-docs.sh` still have `APPLICANT_NAME="Your Name"`?

Greet the user and summarize what you found. For example:

> "Welcome to the Job Search Toolkit. Here's where things stand:
>
> - Preferences.md: not yet created
> - Resume.md: not yet created
> - Cover Letter.md: not yet created
> - cover-letter-header.html: still has placeholder text
> - generate-base-docs.sh: still has placeholder name
>
> We'll set all of these up together. I'll ask questions in batches and show you a preview before writing anything."

If all files already exist and both config files have real data, tell the user the toolkit appears fully configured and explain what each skill does. Then stop -- there is nothing to set up.

If some files exist and others don't, note what's already done and proceed only to the phases that cover missing items.

---

## Phase 1: Contact Information

Ask for all contact fields in a single message:

> "Let's start with your contact info. I'll use this in your resume header, cover letter PDF header, and the build scripts.
>
> Please provide:
> 1. Full name
> 2. Email address
> 3. Phone number
> 4. City and state (e.g., Salt Lake City, UT)
> 5. LinkedIn URL (optional -- skip if you don't have one or prefer not to include it)
> 6. GitHub URL (optional -- skip if not applicable)"

Wait for the user's response. Do not proceed until all required fields (name, email, phone, city/state) are provided. If optional fields are skipped, note that and move on without asking again.

Store all provided contact info for use throughout later phases.

---

## Phase 2: Preferences Interview

Collect preferences in six batches. After each batch, show a formatted preview of what was captured and ask: "Does this look right? Any corrections before we move on?" Wait for confirmation before proceeding to the next batch.

Do not ask one question at a time. Ask the full batch in a single message.

### Batch A: Target Roles

> "What kind of roles are you targeting?
>
> 1. What titles are you looking for? (e.g., CTO, VP of Engineering, Head of Engineering)
> 2. What scope or reporting structure do you want? (e.g., senior-most engineering leader, reporting to the CEO)
> 3. What are you NOT interested in? (e.g., Director-level, IC roles, roles reporting to a non-technical executive)"

### Batch B: Company Criteria

> "What kind of companies do you want to work for?
>
> 1. What funding stage? (e.g., Series A through C, bootstrapped, pre-IPO)
> 2. What industry or product type? (e.g., B2B SaaS, developer tools, fintech)
> 3. Preferred engineering team size (e.g., 10-30 engineers)
> 4. Growth expectations (e.g., must be actively growing, stagnant is a dealbreaker)
> 5. Culture -- what kind of culture are you looking for?"

### Batch C: Compensation

> "Let's talk about compensation.
>
> 1. What's your target total compensation?
> 2. What's your minimum -- the floor below which you won't accept an offer?
> 3. What's your stance on equity? (e.g., important, a nice-to-have, not a factor)"

### Batch D: Location

> "Where are you located and what are your location requirements?
>
> 1. What city or metro area are you based in?
> 2. What's your preferred work arrangement? (e.g., fully remote, remote with occasional travel, hybrid)
> 3. What will you not accept? (e.g., no full-time on-site, no relocation)"

### Batch E: Career Goals and Values

> "Tell me about your career goals and what matters to you at work.
>
> 1. What are you looking for right now (short-term)?
> 2. Where do you want to be in 5-10 years (long-term)?
> 3. What's your sweet spot -- the type of company or role where you do your best work?
> 4. List 3-5 core values that are non-negotiable for you
> 5. What are your work environment must-haves? (things you need to thrive)
> 6. What are your work environment must-nots? (things that will make you miserable or ineffective)"

### Batch F: Personality Profiles and Working Style (Optional)

> "These are optional but genuinely useful -- they help generate more authentic interview talking points and self-awareness responses. Skip anything you haven't done or don't want to include.
>
> 1. Have you taken any personality or work-style assessments? If so, what were the results? (e.g., Myers-Briggs type, Gallup Top 5 strengths, Working Genius types, DiSC profile, Big Five traits)
> 2. How do you prefer to handle conflict at work? (e.g., direct 1:1 conversations only, avoid back-channel)
> 3. What do you need from a CEO or direct manager to do your best work? (e.g., clear vision, autonomy, direct feedback on deficits)
> 4. What reliably frustrates you or gets in your way? (e.g., lack of progress, unclear direction, responsibility without authority)
> 5. Any self-aware weaknesses or blindspots you want on record? (e.g., tendencies that have caused issues before)"

If the user skips this batch or any individual question, note "Not specified" and move on.

### Batch G: Methodology, Voice, and Formatting (Optional)

> "Three optional topics -- skip any you don't have strong preferences on.
>
> 1. Do you have preferred engineering methodologies or practices? (e.g., strong preference for continuous delivery, or particular views on Agile)
> 2. How would you describe your writing voice and tone? (e.g., direct and confident, warm but professional, conversational) Are there phrases, words, or patterns you want to avoid in generated documents? (e.g., clichés like 'passionate about' or 'results-driven', passive voice, filler phrases)
> 3. Any document formatting preferences for your generated resumes and cover letters? (e.g., prefer bullet-heavy, prefer concise)"

If the user skips this batch or passes on individual questions, note "No preferences specified" in the relevant sections and proceed. For the voice question specifically, leave all Candidate Voice fields as their template placeholders if the user skips it.

### After All Batches: Full Preview

Show the complete draft of `Preferences.md` formatted exactly as it will appear in the file, following the structure of `Inputs/Preferences.template.md`. Ask:

> "Here's the full draft of your Preferences.md. Review it carefully -- this file drives filtering in /find-jobs and recommendations in /customize-for-job. Any changes before I write it?"

Wait for explicit approval. Make any requested changes and show the updated draft before writing.

Only write `Inputs/Preferences.md` after receiving explicit approval.

---

## Phase 3: Resume Collection

Ask:

> "Now let's set up your master resume. You have two options:
>
> **Option A:** Paste your existing resume now. I'll reformat it into the toolkit's markdown structure and you can review it before anything is saved.
>
> **Option B:** If you don't have a resume handy, tell me and we'll build one together section by section.
>
> Which do you prefer?"

### If the user pastes an existing resume:

Extract the content and reformat it into the structure from `Inputs/Resume.template.md`:

- H1 heading: their full name (from Phase 1)
- City and state on the next line
- Email, phone, and LinkedIn URL on the next line (pipe-separated), using contact info from Phase 1
- GitHub URL on the line after that (if provided in Phase 1)
- SUMMARY section
- EXPERIENCE section: each role formatted as `**Title | Company (industry descriptor) | Start Month Year - End Month Year**`, followed by a one-sentence impact framing, then bulleted achievements
- TECHNICAL APPROACH section
- COMMUNITY & SPEAKING section (only if they have content -- omit if not present)
- EDUCATION section

If the pasted resume uses different section names, map them to the toolkit structure. If a section exists in the pasted content but has no equivalent in the template, include it at the bottom under a sensible heading -- do not discard content.

If the pasted resume is sparse or missing key sections, note what's thin: "Your resume doesn't have a Technical Approach section yet. You can add one now or leave it as a placeholder." Do not invent content to fill gaps.

Show the full draft and ask:

> "Here's your Resume.md draft. Does this look right? Any corrections, additions, or sections to adjust?"

Wait for explicit approval before writing.

### If the user has no existing resume:

Walk through the resume section by section, starting with the most recent role.

**Step 1:** Current or most recent role:
> "Let's start with your current or most recent role.
>
> 1. Job title
> 2. Company name and what they do (one sentence is fine)
> 3. Start and end dates (or 'Present')
> 4. What was your overall impact at this company? (a sentence or two)
> 5. Your biggest achievements -- quantified results if you have them (list as many as you like)"

**Step 2:** Earlier roles. After each role, ask: "Want to add another role, or move on?" Use the same five questions for each. Continue until the user is done.

**Step 3:** Earlier roles summary: "For roles before [oldest role listed], would you like to add a brief 'Earlier Roles' summary? This is a single paragraph covering titles, companies, and key skills from that period."

**Step 4:** SUMMARY: "Now let's write your professional summary. This is a 2-4 sentence statement at the top of your resume. It should answer: What problem do you solve? What results do you deliver? What makes you distinctive? Based on what you've told me, here's a draft -- correct it as needed:" Draft the summary from collected info, then wait for their edits.

**Step 5:** TECHNICAL APPROACH: "The Technical Approach section is a set of labeled categories describing your approach and tooling. Examples: Engineering practices, Architecture, Platforms, AI enablement, Data. What would you include here?" Collect their input and format it.

**Step 6:** COMMUNITY & SPEAKING (optional): "Do you have any speaking engagements, podcast appearances, open source contributions, or community involvement to include? Skip if not applicable."

**Step 7:** EDUCATION: "Finally, your education: degree, institution, and graduation year."

After collecting all sections, show the complete draft and ask for explicit approval before writing.

After approval (either path), write `Inputs/Resume.md`.

---

## Phase 4: Cover Letter Collection

Ask:

> "Now let's set up your base cover letter. This is the template that /customize-for-job tailors for each specific role.
>
> **Option A:** Paste an existing cover letter. I'll lightly clean and format it.
>
> **Option B:** If you don't have one, I'll draft a strong base cover letter from your resume and preferences.
>
> Which do you prefer?"

### If the user pastes an existing cover letter:

Lightly clean the formatting: fix inconsistent line breaks, standardize spacing, replace any specific company names or role titles with generic placeholders like "[Company]" or "[Role]" so the letter works as a reusable template. Do not rewrite the user's voice or substance.

Show the draft and ask:

> "Here's your Cover Letter.md draft. This is your base template -- /customize-for-job will update the company-specific parts for each application. Does this look right?"

### If the user has no existing cover letter:

Draft a base cover letter using the information from Resume.md and Preferences.md. The base letter should:

- Open with a strong statement of who they are as a candidate and what they bring to engineering leadership roles
- Highlight their core value proposition from the SUMMARY
- Speak to the type of company and stage they want (from Preferences.md)
- Use a closing paragraph that expresses enthusiasm for impact-oriented work
- Stay intentionally generic where /customize-for-job will fill in specifics

Show the draft and ask: "Here's a base cover letter draft. This will be customized for each application, so it intentionally stays generic. What would you like to change?"

Iterate with the user until they approve.

After approval (either path), write `Inputs/Cover Letter.md`.

---

## Phase 5: Configure System Files

Update two configuration files using the contact info from Phase 1. This is a mechanical substitution of already-approved data -- no additional approval is needed.

### 5a: Update cover-letter-header.html

Write `.claude/skills/generate-pdfs/cover-letter-header.html` with the user's real name and contact info:

```html
<div class="header">
  <h1>[Full Name]</h1>
  <p>[email] | [phone] | [City, ST]</p>
  <p>[LinkedIn URL] | [GitHub URL]</p>
</div>
```

- If LinkedIn URL was not provided, omit it from the second `<p>`
- If GitHub URL was not provided, omit it from the second `<p>`
- If neither was provided, omit the second `<p>` entirely

### 5b: Update generate-base-docs.sh

Edit `Scripts/generate-base-docs.sh` and replace:

```
APPLICANT_NAME="Your Name"
```

with:

```
APPLICANT_NAME="[Full Name]"
```

Use the exact full name provided in Phase 1.

After both edits, confirm: "Updated cover-letter-header.html and Scripts/generate-base-docs.sh with your name and contact info."

---

## Phase 6: Completion and Next Steps

Confirm all files written during this session and tell the user exactly what to do next:

> "Setup complete. Here's what was created:
>
> **Inputs/ files:**
> - Inputs/Preferences.md
> - Inputs/Resume.md
> - Inputs/Cover Letter.md
>
> **System files updated:**
> - .claude/skills/generate-pdfs/cover-letter-header.html
> - Scripts/generate-base-docs.sh
>
> **You're ready. Here's how to get started:**
>
> **To find job opportunities:** Run `/find-jobs` -- this searches job boards and VC portfolio pages for roles matching your preferences, then adds leads to a Lead Tracker.
>
> **If you already have a specific posting in mind:** Run `/customize-for-job [url]` -- paste a job posting URL and the toolkit will research the company, identify gaps, and generate a customized resume, cover letter, and interview talking points.
>
> **One optional step before running /find-jobs:** The regional VC job board list in .claude/skills/find-jobs/SKILL.md defaults to Utah-focused VCs. If you're in a different metro, update that section with VCs relevant to your area for better local leads."

If the user already had some files set up and this session only filled in gaps, adjust the summary to reflect only what was created or updated in this session.

---

## Key Rules

- NEVER invent information about the user. Every piece of content in the output files must come from what the user explicitly provided.
- NEVER write any file without first showing a complete draft and receiving explicit approval. Phase 5 is the only exception -- it substitutes data already approved in Phase 1.
- NEVER use em dashes in any output, drafts, or messages.
- Ask questions in batches, not one at a time. The section-by-section resume build (Option B in Phase 3) is necessarily sequential, but even there, ask all questions for each section together.
- If the user already has some files set up, skip those phases entirely. Only collect what is missing.
- If the user skips an optional field (LinkedIn URL, GitHub URL, methodology preferences, formatting preferences), accept that answer and move on without asking again.
- If the user's pasted resume or cover letter is incomplete or sparse, note what's thin and ask if they want to fill it in -- do not silently invent content.
- After writing each file, confirm the path.
- If the user asks to revisit an earlier phase (e.g., wants to change their summary after seeing the cover letter draft), accommodate them before finalizing the later phase.
- Do not run /find-jobs or /customize-for-job automatically after setup. The user chooses what to do next.
