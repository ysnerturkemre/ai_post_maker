# Codex Agent: Rails 8 + Phlex + Bootstrap5 + Turbo/Hotwire (RepoMix Uyumlu)

You are a coding agent working inside a Ruby on Rails application (Rails ~> 8.0.2, Ruby 3.4.x).
The repository uses Phlex and Phlex-Rails for UI, Turbo/Hotwire for interactivity, and Devise for auth.
Your job is to implement requested features/fixes while STRICTLY following the project conventions below.

## Hard Requirements (Non-negotiable)
1) Framework: Ruby on Rails (Rails 8.x).
2) Views/UI: Use **Phlex** (phlex + phlex-rails). Do NOT add ERB views for new pages unless explicitly requested.
3) CSS Framework: Use **Bootstrap 5** classes and patterns.
4) Forms: Use **bootstrap_form** gem builders for forms (BootstrapForm).
5) Interactivity: Use **Turbo Frames / Turbo Streams + Hotwire (Turbo + Stimulus)**. Prefer progressive enhancement.

If any existing code contradicts these rules, keep backward compatibility but implement new work according to these rules.

## 🚫 Tailwind Policy (Strict)
- Do NOT introduce Tailwind-based UI for new work (even if Tailwind exists in Gemfile/stylesheets).
- Do NOT output Tailwind utility classes (e.g., flex, gap-4, text-gray-500, bg-blue-600).
- Do NOT mix Tailwind with Bootstrap.
- If Tailwind code exists in the files you touch, you MUST convert it to **Bootstrap 5** equivalents.

### ✅ Mandatory Conversion Rule (If Tailwind Exists)
When editing any file that contains Tailwind:
- Replace Tailwind classes with **Bootstrap 5** classes.
- Replace Tailwind-based forms with **bootstrap_form** (BootstrapForm) helpers.
- Keep the same UI intent/behavior (layout, spacing, responsiveness) using Bootstrap 5 grid/utilities.
- Do NOT leave “both” (Tailwind + Bootstrap).
- If full conversion is too large, convert at least the changed/adjacent sections and clearly note remaining Tailwind areas.

---
## Context Enforcement
All agents MUST:
- Read docs/context.md before coding
- Treat it as authoritative documentation
- Prefer existing patterns over assumptions
- Stop and ask if context is missing


## 🧠 Task Management — Beads (MANDATORY)

This repository uses **Beads (`bd`) as the single source of truth** for planning, task tracking, and agent workflow.

### 🔒 Beads Workflow Rules (STRICT)
1) **Before starting ANY work**, you MUST run:
   ```bash
   bd ready
