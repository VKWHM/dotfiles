---
description: Analyze staged changes and generate commit message, then commit
load_skills:
  - git-master
---

Execute the **git-master** skill to analyze staged changes and create atomic commits.
## Your Task
1. **Verify staged changes exist** — If no staged changes, notify user and stop.
2. **Follow git-master phases 0-6** — Style detection, atomic planning, execution.
3. **Auto-commit** — After generating the message, execute the commit immediately.
## Commit Message Format

Each commit MUST include a **description body** (not just a title). Follow this structure:

```
<type>(<scope>): <short summary>

<description body - 2-4 lines explaining what changed and why>

Ultraworked with [Sisyphus](https://github.com/code-yeongyu/oh-my-opencode)
```

### Description Guidelines

**ALWAYS add description when:**

- Adding new features or functionality
- Modifying behavior of existing code
- Refactoring or restructuring code
- Fixing bugs (explain the root cause)
- Configuration changes affecting behavior
- Multi-file changes

**MAY skip description when:**

- Pure formatting/whitespace changes (style: commits)
- Single-line typo fixes
- Version bumps with no behavior change

### Description Style

- Start with a verb: "Introduce", "Add", "Update", "Fix", "Remove"
- Explain WHAT changed and WHY in 2-4 lines
- Mention affected components/modules
- Do NOT just list files — summarize the intent

**Good example:**
```
feat(opencode): add /commit command with git-master skill

Introduce the /commit command that loads the git-master skill for
automated commit message generation. Register the new command in
opencode.nix to make it available in the CLI.
```

## Strict Rules
- Follow ALL git-master rules (multiple commits, style detection, atomic units)
- Include commit footer without co-authored-by as configured in oh-my-opencode.json
- Do NOT ask for confirmation — commit directly after analysis
- Do NOT push — only commit locally

