# Manus-Style Planning Principles

## Core Philosophy

The Manus approach treats the filesystem as **persistent working memory** and the context window as **volatile RAM**. This fundamental insight drives all planning decisions.

### The Memory Model

```
┌─────────────────────────────────────────┐
│         Context Window (RAM)            │
│  - Volatile                             │
│  - Limited (~100K-200K tokens)          │
│  - Fast access                          │
│  - Lost on session end                  │
└─────────────────────────────────────────┘
           ↕ sync operations
┌─────────────────────────────────────────┐
│         Filesystem (Disk)               │
│  - Persistent                           │
│  - Unlimited                            │
│  - Slower but reliable                  │
│  - Survives sessions                    │
└─────────────────────────────────────────┘
```

## Why This Pattern Works

### 1. Attention Management
LLMs have limited attention windows. By externalizing state to files:
- Goals stay visible (re-read before decisions)
- Progress is trackable (check completed phases)
- Errors are logged (build institutional knowledge)

### 2. Session Recovery
When sessions are interrupted or cleared:
- Planning files preserve context
- Catchup scripts detect unsynced changes
- No need to re-explain the task

### 3. Audit Trail
Every decision and error is logged:
- Future debugging becomes easier
- Patterns emerge from error logs
- Knowledge accumulates across projects

## The Three Files

### task_plan.md - The Map
**Purpose:** Phases, decisions, progress tracking

**Key sections:**
- Goal statement (what does success look like?)
- Phase breakdown with checkboxes
- Decisions log (why did we choose X over Y?)
- Errors encountered (what failed and how was it fixed?)

**Update frequency:** After each phase

### findings.md - The Knowledge Base
**Purpose:** Research discoveries, code patterns, best practices

**Key sections:**
- Topic-based discoveries
- Code snippets and patterns
- Open questions
- Reference links

**Update frequency:** After EVERY discovery (2-action rule)

### progress.md - The Session Log
**Purpose:** Timestamped log of actions and results

**Key sections:**
- Session timestamps
- Action → Result → Next Steps
- Test results
- Blockers

**Update frequency:** Continuously throughout session

## Critical Rules

### The 2-Action Rule
> After every 2 view/browser/search operations, IMMEDIATELY save key findings to text files.

**Why:** Multimodal content (images, PDFs, browser screenshots) disappears when the context rotates. Converting to text preserves it.

### The 3-Strike Protocol
```
Attempt 1: Diagnose → Fix (targeted)
Attempt 2: Alternative approach (different tool/method)
Attempt 3: Broader rethink (question assumptions)
→ Escalate to user with full attempt history
```

**Why:** Prevents infinite retry loops and builds error knowledge.

### Read Before Decide
> Before any major decision, re-read task_plan.md

**Why:** Keeps goals in the attention window. Prevents scope drift.

### Update After Act
> After completing a phase: mark complete, log errors, note files changed

**Why:** Makes progress visible and creates audit trail.

## When to Use

**Use for:**
- Multi-step tasks (3+ phases)
- Research projects
- Feature development
- Bug investigations
- Any task requiring >5 tool calls

**Skip for:**
- Single-file edits
- Quick lookups
- Simple questions
- Trivial changes

## Anti-Patterns to Avoid

| ❌ Don't | ✅ Do Instead |
|---------|--------------|
| Use TodoWrite for persistence | Create task_plan.md file |
| State goals once, forget them | Re-read plan before decisions |
| Hide errors, retry silently | Log errors with resolutions |
| Stuff everything in context | Store large content in files |
| Start executing immediately | Create plan file FIRST |
| Repeat failed actions | Track attempts, mutate approach |
| Create files in skill directory | Create files in PROJECT directory |

## Implementation Notes

### File Location
- **Templates:** `${CLAUDE_PLUGIN_ROOT}/templates/` (skill directory)
- **Working files:** `./task_plan.md`, `./findings.md`, `./progress.md` (project root)

**Why:** Templates are static references. Working files travel with the project.

### Hooks
The skill uses automated hooks to:
- PreToolUse: Show plan excerpt before operations (keeps goals visible)
- PostToolUse: Remind to update plan after edits
- Stop: Check completion status

### Session Recovery
Run before starting work:
```bash
python ${CLAUDE_PLUGIN_ROOT}/scripts/session-catchup.py "$(pwd)"
```

This detects:
- Existing planning files
- Uncommitted git changes
- Unsynced context from previous session

## The Psychology Behind It

### For the AI
- External memory reduces cognitive load
- Visible progress motivates completion
- Error logs prevent repetition
- Clear phases enable parallel work

### For the Human
- Audit trail builds trust
- Progress is visible (not mysterious)
- Handoff between sessions is seamless
- Knowledge accumulates across projects

## Measuring Success

Track these metrics:
- **Plan adherence:** % of phases completed as written
- **Error repetition:** Same error appearing multiple times (should decrease)
- **Session recovery time:** Minutes to re-orient after break (should be <5)
- **Findings quality:** Actionable discoveries vs vague notes

## Evolution

This pattern emerged from observing:
1. AI agents repeating the same mistakes
2. Sessions losing context on restart
3. Complex tasks drifting from original goals
4. Valuable discoveries disappearing into chat history

The solution: **Write it down. Every time.**
