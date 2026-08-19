Generate a concise "What's new" section from the changes between the base and head refs.

Requirements:
- Return only Markdown bullet points. Do not include a heading.
- Combine related commits into a single change.
- Do not describe individual commits.
- Summarize the user-visible result rather than the implementation details.
- Ignore purely internal refactoring unless it has a user-visible impact.
- Do not mention commit hashes, PR numbers, or contributors.
- Each bullet should describe one meaningful change.
- Keep each bullet concise, ideally one sentence.
- Do not invent features or behavior that are not supported by the changes.
