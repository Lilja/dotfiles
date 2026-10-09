---
name: weekly-recap
description: Summarize the user's GitHub PRs and Slack activity over a time window (default: the past 7 days) and DM them the digest. Use when the user wants a recap of what they shipped/discussed this week, or asks for the same for another week/date range.
---

Determine the date range first: default to the last 7 days ending today. If the user names a different window ("last week", "the week of Oct 2", "past two weeks"), resolve it to explicit start/end dates before continuing.

## Gather GitHub activity

Use `gh search prs` (not `gh pr list`, which can't filter by date across repos):

- Authored, touched in range: `gh search prs --author=@me --updated=">=START" --json number,title,repository,state,url,createdAt,mergedAt,updatedAt`
- Reviewed by the user in range: `gh search prs --reviewed-by=@me --updated=">=START" --json number,title,repository,state,url,updatedAt`

Split authored PRs into **merged in range** (shipped) vs **still open** (in progress). Skip PRs whose only activity in range is a bot comment or rebase.

## Gather Slack activity

Search the user's own messages, not full channel history:

- `slack_search_public_and_private` (or `slack_search_public` if private search isn't available) with query `from:me after:START before:END`
- For threads that look substantive (design discussions, decisions, incident updates), use `slack_read_thread` to get the full context rather than guessing from a snippet.

Filter out noise: reactions, one-word acks, status-check bot output. Keep messages that represent a decision made, a question answered, a problem debugged, or an announcement.

## Synthesize

Group everything by project/repo. For each item write one line: what happened and why it mattered, not a changelog restatement of the title. Drop anything too trivial to be worth a recap line (typo fixes, dependency bumps) unless nothing else happened that week.

Use this format for the digest:

```
*Weekly recap — Oct 6–12*

*Shipped*
• <repo>: <one-line summary> (<PR link>)
• <repo>: <one-line summary> (<PR link>)

*In progress*
• <repo>: <one-line summary, what's blocking if anything> (<PR link>)

*Reviewed*
• <repo>: <one-line summary of what you reviewed> (<PR link>)

*Discussions & decisions*
• <topic>: <decision or outcome, one line> (<Slack link>)
```

Omit any section with nothing in it. If a section would only have one trivial item, fold it into another rather than leaving a near-empty header.

## Post it

Show the drafted digest in chat first. Resolve the user's own Slack ID (e.g. via `slack_read_user_profile` or `slack_search_users` for "me") to address their self-DM, then send with `slack_send_message`. Confirm with the user before sending unless they've explicitly asked to skip confirmation (e.g. running this on a recurring `/loop`).
