---
name: compact-experience-bank
description: Compact the Experience Bank by merging redundant entries into topic-based format
---

Reorganize `Inputs/experience-bank.md` from job-specific Q&A entries into a topic-based format that is easier to scan and reuse across future applications.

## Input

No arguments needed. The skill always operates on `Inputs/experience-bank.md`.

## Output Format

The compacted Experience Bank replaces the current file content with topic-based entries:

```markdown
# Experience Bank

Accumulated knowledge about your experience, organized by topic.
Compacted: [date]

## [Topic Name]
[Generalized description of the skill/experience area]
- **[Subtopic/Technology]:** [Companies where used, level of experience, notable details]
- **[Subtopic/Technology]:** ...
**Tags:** [comma-separated tags]
```

Example:

```markdown
## Databases
Extensive experience with both relational and non-relational databases across multiple companies.
- **PostgreSQL:** Startup A, Startup B (primary production database)
- **MySQL:** Startup C (legacy system migration)
- **Redis:** Startup A (caching layer)
**Tags:** PostgreSQL, MySQL, Redis, RDBMS, databases
```

## Process

### Step 1: Read the current bank

Read `Inputs/experience-bank.md`. The file may contain:
- **Q&A entries** (from customize-for-job appends): headed with `## [Date] - [Company / Role]` followed by Question/Answer/Tags
- **Topic entries** (from previous compactions): headed with `## [Topic Name]` followed by description, subtopics, and tags
- **A mix of both** if new Q&A entries were appended after a previous compaction

### Step 2: Analyze and cluster

Examine all entries and identify:
- **Clusters of related topics** (e.g., all database mentions across entries, all cloud platform mentions, all security mentions)
- **Redundant information** that appears in multiple entries
- **Gaps:** technologies or skills mentioned without a company, adjacent skills that should logically be captured but aren't (e.g., a database is listed but no company or use case is attached)

### Step 3: Propose topic groupings

Present the proposed topic groupings to the user as a numbered list. For example:
1. Databases
2. Cloud Platforms (Azure, AWS, GCP)
3. Security & Compliance
4. ...

Ask the user if they want to adjust, merge, or split any topics before proceeding.

### Step 4: Ask gap-filling questions

Present all identified gaps as a single batch of questions. Frame each specifically:
- "PostgreSQL is listed in your database experience but no company is attached. Where did you use it and for what?"
- "You mention Kafka experience at the architecture level. Did you also work with any other message brokers or event streaming tools?"

Wait for answers before proceeding.

### Step 5: Write the compacted file

Replace the content of `Inputs/experience-bank.md` with the compacted, topic-based format. Ensure:
- Every fact from the original bank appears in the compacted version
- Companies are preserved as context for where each skill was used
- Proficiency qualifiers are preserved (e.g., "limited proficiency," "architecture-level only," "not the primary developer")
- No job-application framing remains (no "Company X prompted this question" language)
- The header includes the compaction date

### Step 5.5: Enforce size budget

The Experience Bank is read by every `/customize-for-job` run, so its size has a recurring context cost. The target budget is **~50 KB or ~250 lines for the main body**, whichever is larger.

If the compacted file exceeds the budget, do not delete content. Instead, demote secondary detail into a `## Detail Reservoir` section at the bottom of the file. Reservoir candidates include:

- Verbatim podcast quotes once the insight is captured in a topic section (keep the citation, drop the quote text)
- Hyper-specific technical minutiae (exact CLI flags, config filenames) that round out a topic but rarely surface in a job application
- Per-company anecdotes whose lesson is already represented in a more general bullet
- Redundant phrasings that overlap with a higher-priority bullet in the same topic

What stays in the main body:

- Topic headlines, the per-topic summary line, and the tagged bullets that describe *what* the candidate has done where
- Genuine gaps and explicit "limited proficiency" or "no experience" assessments (these matter for honest matching)
- Anything tagged with a skill or technology that frequently appears in job descriptions

Format the Detail Reservoir as:

```markdown
## Detail Reservoir

Reference material. Browse only when a gap analysis specifically calls for depth on one of these tags.

### [Topic Name] (details)
- [demoted bullet]
- [demoted bullet]
**Tags:** [comma-separated tags from the parent topic]
```

After demotion, re-check the size. Stop when the main body fits the budget. If demotion alone cannot get the file under budget, surface the overage to the user with specific recommendations rather than dropping content silently.

### Step 6: Present summary

Show the user:
- Number of original entries merged
- Topics created
- Gaps that were filled
- Any information that was ambiguous or needed judgment calls

## Important Rules

- NEVER discard information. Every fact from the original bank must appear in the compacted version.
- NEVER invent experience or details.
- NEVER use em dashes in any output. Use other punctuation instead.
- Preserve honest assessments of proficiency level. Do not upgrade "limited proficiency" to "experience with."
- Personal entries (e.g., language fluency, volunteer work, values) should become their own topic, not dropped.
- Keep tags on each topic section for searchability by future customize-for-job runs.
- If the bank has already been compacted and only has new Q&A entries appended at the bottom, merge just the new entries into the existing topic structure rather than rebuilding from scratch.
