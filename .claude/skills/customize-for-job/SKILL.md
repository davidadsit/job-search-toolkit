---
name: customize-for-job
description: Customize resume and cover letter for a specific job description
argument-hint: [job-url-or-paste]
---

Customize your resume, cover letter, and interview prep for a specific job opportunity.

## Input

The argument may be:
- A URL to a job posting (fetch it with WebFetch)
- Pasted job description text that follows this command

If no argument is provided, ask the user to paste or link the job description.

**When the job description is fetched from a URL:** When fetching, explicitly ask for compensation/salary data in the WebFetch prompt. Many job postings include salary ranges in metadata, structured data, or fine print that can be missed if not specifically requested. Save the fetched content as `Applications/CompanyName/jd.md` with the source URL in a header. Include any compensation data found. Format:

```markdown
# Job Description

*Source: [URL]*

[fetched job description content]
```

Create the `Applications/CompanyName/` directory as needed. This file serves as a local reference so the original posting is preserved even if the URL goes down.

## Process

### Phase 0: Lead Tracker Check

Before doing any work, check `Lead Tracker.md` for the company name:

1. Read `Lead Tracker.md` and search for the company name.
2. **If found in Closed Leads:** Stop immediately. Tell the user the company was previously evaluated and closed, include the closure reason, and ask if they want to proceed anyway.
3. **If found in Active Leads:** Note the existing status and proceed, updating the existing entry rather than creating a duplicate.
4. **If not found:** Proceed to Phase 1.

### Phase 1: Company Research

Before customizing any documents, research the target company to inform all subsequent phases.

**Web request strategy:** Use WebFetch by default for all research requests. Fall back to Playwright (`browser_navigate` then `browser_snapshot`) only if WebFetch returns a login redirect, an empty body, or fewer than ~200 characters of useful content. Playwright runs headless -- no visible browser window.

#### Step 1: Identify the company

Extract the company name, website, and identifying details from the job posting. Handle three cases:

- **Company clearly named:** Proceed with research.
- **Confidential posting:** Extract every identifying detail (industry, stage, product description, client names, location, employee count). Use `WebSearch` to attempt identification with a query combining those details. If a strong match is found, confirm with the user: "Based on the job description details, this appears to be [CompanyName]. Should I research this company, or would you prefer to skip company research?" If no match or user declines, create a minimal profile from job description details only and mark sections as "Not available - confidential posting."
- **No useful identifying information:** Skip research. Inform the user: "I couldn't identify the company from the job posting. Skipping company research." Proceed to Phase 2.

#### Step 2: Research the company website

Using `WebSearch` and `WebFetch` (3-4 WebFetch calls max on the company site):

1. Find the company's main website if not already known from the job posting.
2. Fetch and extract key information from:
   - Homepage (what the company does, how they position themselves)
   - About page (`/about`, `/about-us`, or similar)
   - Team/leadership page (`/team`, `/about/team`, `/leadership`, or similar)
   - Careers/culture page if easily found
3. If a page 404s or redirects unhelpfully, move on.

#### Step 3: Research funding and financials

Use `WebSearch` to find:

1. Crunchbase profile: search `[CompanyName] crunchbase`
2. Recent funding news: search `[CompanyName] funding round`
3. Revenue or valuation data: search `[CompanyName] revenue valuation`
4. Recent news: search `[CompanyName] news`

Extract: total funding, last round details (amount, date, investors), estimated valuation if available, employee count, growth signals.

5. Compensation data: search `[CompanyName] [RoleTitle] salary` and `[RoleTitle] salary [Industry] [Stage]`. Check the job posting itself for any listed salary range. Note whether the posted range aligns with your target compensation from `Inputs/Preferences.md`.

#### Step 4: Research leadership team

Use `WebSearch` to find information about key executives (CEO, CTO, VP Engineering, and the hiring manager if identifiable):

1. Search `[CompanyName] [Title]` for each key role
2. Search `[ExecutiveName] LinkedIn` to find public profile URLs
3. Use `WebFetch` on public LinkedIn profile URLs (these show name, title, and summary without authentication)
4. Search for conference talks, blog posts, or interviews by key leaders

Focus on: the person the candidate would report to, and the CEO. Understanding their backgrounds helps tailor the pitch.

#### Step 5: Create Company Profile

Create `Applications/CompanyName/Company Profile - CompanyName.md` with this structure:

```markdown
# Company Profile - [CompanyName]

*Researched: [Date]*
*Source: [Job posting URL or "pasted job description"]*

## Company Overview
- **Name:** [CompanyName]
- **Website:** [URL]
- **Industry:** [Industry]
- **Founded:** [Year if found]
- **Headquarters:** [Location]
- **Employee Count:** [Count and source]
- **Stage:** [Seed / Series A / Series B / ... / Public / Bootstrapped]

## What They Do
[2-3 sentence description of the company's product/service. What problem do they solve? Who are their customers?]

## Product and Technology
- **Core Product:** [Product name and what it does]
- **Tech Stack:** [Technologies mentioned in JD, website, or job postings]
- **Technical Challenges:** [Inferred from JD and product - what are the hard engineering problems?]

## Funding and Financials
- **Total Funding:** [Amount if known]
- **Last Round:** [Series X, $Amount, Date, Lead investors]
- **Valuation:** [If publicly available]
- **Revenue Signals:** [Any available data - ARR, revenue range, growth rate]
- **Key Investors:** [Notable investors]
- **Compensation Range:** [Posted salary range if listed in JD, or market data if found. Note alignment with your target compensation from Preferences.md.]

## Leadership Team
### [Name] - [Title]
- **Background:** [Previous companies, relevant experience]
- **LinkedIn:** [Public profile URL]
- **Notable:** [Conference talks, blog posts, public statements about engineering culture]

[Repeat for each key leader found]

## Culture and Values
[What the company says about its culture. Signals from careers page, leadership public statements. Note the source.]

## Recent News
- [Date] - [Headline and one-sentence summary with source]
- [Date] - [Headline and one-sentence summary with source]

## Relevance to Candidate
- **Stage match:** [How does the company's stage/size compare to where the candidate has thrived?]
- **Technical alignment:** [How does the stack/challenges match the candidate's experience?]
- **Leadership opportunity:** [What kind of impact could the candidate have here?]
- **Compensation fit:** [Does the posted range or market data support the target? Is it above the minimum? Flag if range tops out below the minimum.]
- **Potential concerns:** [Anything that stands out as a yellow flag]
- **Recommendation:** [Apply / Apply with caveats / Don't apply] - [one-sentence justification]

## Research Gaps
[List anything that could not be found. These become interview questions.]
```

Mark any section where data was not found as "No data found" rather than omitting it.

### Phase 2: Read all inputs

1. **Read the job description** carefully. Identify:
   - Company name, stage, and industry
   - Role title and reporting structure
   - Key responsibilities
   - Required and preferred qualifications
   - Tech stack mentioned
   - Any cultural signals or values

2. **Build an ATS keyword inventory** from the job description. Extract three categories, capturing each term in the JD's exact form (e.g., "CI/CD" not "continuous integration"):
   - **Hard skills and technologies:** Every specific tool, framework, language, platform, and methodology named in the JD, including items from both the requirements and tech stack sections.
   - **Role-specific terms:** Domain terms, industry jargon, and role descriptors (e.g., "microservices," "B2B SaaS," "Agile," "distributed systems").
   - **Soft skills and leadership terms:** Phrases like "mentoring," "cross-functional collaboration," "ownership mindset," "hiring."

   For each keyword, note whether it appears in a "required" or "preferred" context. This inventory is a working list used in Phases 4, 4.5, and 6.

3. **Read all source documents** (read-only, never modify these):
   - `Inputs/Preferences.md`
   - `Inputs/Resume.md`
   - `Inputs/Cover Letter.md`
   - `Inputs/Experience Bank.md` (if it exists; skip without error if not)

   After reading `Inputs/Preferences.md`, extract and hold three sections as standing references for Phase 4:
   - **Candidate Voice** (if present): tone, style, vocabulary, and things to avoid in every generated document
   - **Personality Profiles** (if present): assessment results (Myers-Briggs, Gallup, DiSC, etc.) that inform authentic self-awareness language in interview talking points
   - **Working Style** (if present): conflict resolution approach, needs from manager/CEO, frustration triggers, and self-aware weaknesses -- use these to write more honest and specific interview talking points and cover letter framing

4. **Read the Company Profile** created in Phase 1 (`Applications/CompanyName/Company Profile - CompanyName.md`) to inform gap analysis and output tailoring.

### Phase 3: Gap analysis and inquiry

1. Compare every required and preferred qualification from the job description against ALL source documents and the Experience Bank.
2. Identify any requirement where the candidate's documented experience does not clearly demonstrate a match.
3. Present ALL identified gaps as a numbered list and ASK the user about each one. Frame questions specifically, e.g.: "The job requires X. I don't see this covered in your documents. Do you have experience with X, or something closely related?" Never assume the candidate lacks experience just because it is not documented.
4. **Wait for the user to answer before proceeding.** Do not generate any output files until the user has responded.
5. After receiving answers, append any new information to `Inputs/Experience Bank.md` (create the file if it does not exist). Use the format described below.
6. Classify each requirement as:
   - **Fully covered** - candidate has clear, documented experience
   - **Partially covered** - candidate has transferable skills or adjacent experience
   - **Genuine gap** - No relevant experience after asking

### Phase 4: Create output files

Create all files in `Applications/CompanyName/`. Name resume and cover letter files using the applicant's name from `Inputs/Resume.md` (the H1 heading at the top).

#### 1. `[FirstName LastName] - Resume - CompanyName.md`
- Do NOT fabricate experience or skills the candidate doesn't have
- Reorder bullets within each role to lead with the most relevant ones for this job
- Adjust the summary to emphasize the aspects most relevant to this role; apply the Candidate Voice from Preferences.md (tone, style, things to avoid)
- Incorporate relevant information from the Experience Bank that strengthens the fit
- Keep all formatting consistent with the base resume

**ATS keyword optimization:**
- Each **required** keyword from the Phase 2 keyword inventory must appear at least once in the resume, in a contextual sentence (not a keyword dump). If a keyword corresponds to experience the candidate has but the base resume uses different terminology, use the JD's exact term (or both). For example, if the JD says "CI/CD" and the base resume says "continuous integration," use "CI/CD."
- In the Technical Approach section, mirror the JD's technology terms exactly. If the JD lists specific services (e.g., "ECS, EKS, Lambda, RDS") and the candidate has used them, include those specifics rather than just the platform name.
- For technologies in the JD that the candidate has used but the base resume does not mention, add them to the Technical Approach section or weave them into relevant experience bullets. Only add technologies the candidate has genuinely used.
- For technologies the candidate has not used, do not add them. They should already be flagged in the gap analysis.
- Never create a standalone "Keywords" or "Skills" section that is just a keyword list. ATS AI screeners give much more weight to keywords that appear in experience descriptions with context than to keyword lists.
- Cap any single keyword at 3 occurrences in the resume to avoid triggering stuffing detection.

**ATS structure guardrails:**
- Maintain standard section headings consistent with the base resume. Do not rename them.
- Within EXPERIENCE, always use the format: `**Title | Company (description) | Dates**`. Do not rearrange the order.
- Use consistent date formats: `Month Year - Month Year` (e.g., "August 2022 - January 2026"). No abbreviations or formats like "2022-2026."
- No tables, columns, text boxes, or images.

#### 2. `[FirstName LastName] - Cover Letter - CompanyName.md`
- Update the opening to connect the candidate's value prop to this company's specific situation
- Adjust emphasis to match job priorities
- For any genuine remaining gaps, honestly acknowledge them in the cover letter. Frame each gap with transferable skills and a concrete plan to bridge it. Never omit or hide gaps.
- Reference specific company details from the Company Profile (funding stage, product, mission) to demonstrate genuine research and interest. Weave them into the narrative naturally; do not simply list facts.
- Apply the **Candidate Voice** from `Inputs/Preferences.md`: match the specified tone, follow the style guidelines, and avoid anything listed under "Avoid." This takes precedence over the base cover letter's existing style -- if the base letter deviates from Preferences.md voice, correct toward Preferences.md.
- If the candidate's most recent role ended in a way that might raise questions (e.g., company contraction, org restructure, unusual tenure length, or a departure that doesn't speak for itself), include a brief "Why I left [Company]" paragraph. Keep it 2-3 sentences: what was accomplished, why it was the right time to move on, and that it ended well. Proactively addressing a potentially confusing departure builds trust. If the departure is straightforward and self-evident, omit this.
- Do NOT use em dashes. Use other punctuation instead.
- **ATS keyword reinforcement:** Many ATS platforms parse and score cover letters alongside resumes. Reinforce the top 5-7 required keywords from the keyword inventory using the JD's exact terms. Do not treat the cover letter as a second keyword-stuffing opportunity; it should remain a persuasive narrative.

#### 3. `Interview Talking Points - CompanyName.md`
- **Strengths to emphasize:** Where the candidate's experience directly matches key requirements
- **Gap responses:** For each gap or partial match, provide a clear talking point that frames transferable skills, shows self-awareness, and describes a concrete plan to close the gap. If **Working Style** is present in Preferences.md, use the self-aware weaknesses and frustration triggers to add specificity and honesty to gap responses.
- **Leadership style:** Use **Personality Profiles** (if present) to write an authentic "how I lead" narrative. Don't quote assessment labels directly in interview answers -- translate them into concrete behaviors. Use **Working Style** (conflict resolution, needs from manager) to prepare for questions about team dynamics and what you need to thrive.
- **Company-specific points:** Draw from the Company Profile for specific data points: funding, leadership backgrounds, recent news, technical challenges.
- **Questions to ask:** Thoughtful questions the candidate can ask the interviewer, tailored to this role and company. Use Research Gaps from the Company Profile to generate questions about things not found through research. Use the **Working Style** "needs from manager/CEO" field to generate questions that screen for the candidate's own requirements.

### Phase 4.5: ATS Keyword Verification

Before proceeding, review the customized resume against the keyword inventory from Phase 2.

1. **Required keyword check:** For each required keyword, verify it appears in the resume. For each missing keyword:
   - If the candidate has the experience: revise the resume to include the term naturally in an experience bullet or technical section.
   - If the candidate does not have the experience: confirm it was addressed in the gap analysis. Do not add it.

2. **Preferred keyword check:** For each preferred keyword, check whether it appears. Missing preferred keywords are acceptable if the candidate lacks the experience, but if they have it and it is simply absent, add it.

3. **Terminology alignment check:** Scan for cases where the resume uses a synonym or alternate form of a JD keyword. Add the JD's exact term alongside or in place of the synonym.

4. **Keyword-in-context check:** Verify that critical keywords appear in experience bullets, not just in a skills or technical section. ATS AI screeners weight keywords higher when they appear in descriptions of what you did.

5. **Density sanity check:** If any keyword appears more than 3 times in the resume, reduce it. Keyword stuffing triggers spam detection in modern AI screeners.

### Phase 5: Update Company Profile

Now that the gap analysis and customization are complete, revisit the Company Profile to update the "Relevance to Candidate" section with the fuller picture:

1. Re-read `Applications/CompanyName/Company Profile - CompanyName.md`
2. Update the "Relevance to Candidate" section to reflect specifics learned from the gap analysis, Experience Bank answers, and customization work.
3. **Recommendation** should be one of:
   - **Apply** - strong match for this role
   - **Apply with caveats** - reasonable match but there are notable gaps or concerns (list them)
   - **Don't apply** - the gaps or concerns are significant enough that this is not a good use of time
4. Save the updated Company Profile.

### Phase 5.5: Update Lead Tracker

Add or update this lead in `Lead Tracker.md`:

1. Read `Lead Tracker.md` (if it exists). If it does not exist, create it using the template format from `/find-jobs`.
2. Check if this company + role already appears in the tracker.
   - **If found:** Update its status to "Researching - customized materials generated" and add the application folder path. If the existing entry already has a more advanced status (e.g., "Applied", "Interviewing", "On Pause"), preserve that status and only update the application folder path and notes.
   - **If not found:** Add a new entry in the **Researching** section with source, discovered date (today), stage, URL, status "Researching - customized materials generated", application folder path, and relevant notes.
3. Update the **Pipeline Summary** counts to reflect the change.

**Note:** Do not mark the lead as "Applied." The user will indicate when they have actually submitted an application.

### Phase 6: Present summary

After creating all files and updating the Company Profile, present:
- Key findings from company research and any research gaps to investigate independently
- What was emphasized/reordered in the resume and why
- How gaps were framed in the cover letter
- What new information was added to the Experience Bank
- A brief overview of the interview talking points
- **ATS keyword coverage:** Report the percentage of required and preferred keywords present in the resume. List any missing keywords with the reason (genuine gap or deliberate omission).
- The apply/don't apply recommendation and rationale

## Experience Bank Format

The Experience Bank may be in one of two formats:
- **Q&A format:** Individual question/answer entries from gap analysis sessions
- **Compacted topic format:** Entries organized by topic after running `/compact-experience-bank`
- **A mix of both:** Compacted topics with new Q&A entries appended at the bottom

Read whichever format is present. When appending new entries, always use the Q&A format below (append at the end of the file regardless of the existing format):

```
## [Date] - [Company Name / Role Title]

**Question:** [The gap question that was asked]
**Answer:** [What the candidate said]
**Tags:** [comma-separated skill/technology tags for easy searching]
```

If creating the file for the first time, add this header:

```
# Experience Bank

Accumulated knowledge about your experience, organized by topic.
```

## Important Rules

- NEVER invent experience, skills, or accomplishments
- NEVER fabricate company research data; mark unknown items as "No data found"
- NEVER attempt automated login to LinkedIn or any authenticated service
- NEVER store credentials or API keys in project files
- NEVER use em dashes in any output
- NEVER add invisible, white-text, zero-font-size, or hidden keyword sections to resumes or cover letters. Modern ATS AI screeners detect and penalize these techniques.
- NEVER modify the base resume, base cover letter, or this skill definition file
- ALWAYS confirm with the user before researching a company identified from a confidential posting
- ALWAYS create the Company Profile before reading source documents, so research informs all subsequent phases
- ALWAYS ask about gaps before assuming the candidate lacks experience
- ALWAYS read the Experience Bank (if it exists) before gap analysis
- ALWAYS append new information to the Experience Bank after user answers
- ALWAYS apply the Candidate Voice from `Inputs/Preferences.md` when generating or customizing any document. If the section is absent, infer voice from the base cover letter's existing style.
- The base documents are the source of truth. Only rearrange and emphasize, don't rewrite the core narrative.
- Always create new files in the Applications subfolder.
- Keep company research efficient: aim for no more than ~10 WebSearch calls and ~8 WebFetch calls for the entire research phase.
