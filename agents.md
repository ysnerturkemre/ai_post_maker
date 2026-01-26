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

## 🚫 Ticket & Status Rules (Hard)

- The agent MUST NOT change ticket status to "Done", "Completed", or equivalent without EXPLICIT user approval.
- The agent MUST ask for approval before closing or marking any ticket as done.
- If unsure, the agent must leave the ticket in "In Progress".
- Silence is NOT approval.

## Beads Ticket Completion Policy (MANDATORY)

This project uses Beads for planning and execution tracking.
Ticket completion rules are STRICT and must be followed.

### Dependency Semantics
- "Depends on" = PARENT tickets
- "Blocking" = CHILD tickets

### Completion Rules
1) ONLY close the ticket that was explicitly implemented.
2) NEVER auto-close dependency tickets listed under "Depends on".
3) NEVER close parent tickets or epics unless explicitly instructed by the user.
4) Completing a child ticket does NOT imply its parent is complete.
5) Epics are closed manually by the user only, after all child tickets are done.

### Practical Rule of Thumb
- If a ticket has "Depends on" entries → it is a CHILD → you may close ONLY this ticket.
- If a ticket has "Blocking" entries → it is a PARENT → DO NOT close it.

### Enforcement
- Do not ask to close dependencies.
- Do not suggest bulk or cascading closures.
- When in doubt, leave tickets OPEN and ask the user.

Violating these rules breaks project tracking integrity.

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

## Product Vision & Roadmap (Authoritative)

### V1 – MVP (Current Focus)
Goal: Deliver an end-to-end working flow for manual social media content creation using a fully local and free AI stack.

Scope:
- Prompt → **image generation via ComfyUI (local GPU)** (success/failure handled)
- Prompt → **video generation via ComfyUI (local GPU)** (short clip; success/failure handled)
- Store generated assets (image/video) on Post via ActiveStorage
- Store generation metadata on Post (prompt + workflow JSON + provider info)
- Caption generation is **template-based** (no external LLM required in V1)
- Display caption + generated asset(s) in UI
- Manual sharing UX:
  - Copy caption
  - Open Instagram (web)
  - Download generated image/video
- CI (lint + tests) must pass

Non-goals (explicitly out of scope for V1):
- Cloud or paid AI providers (Gemini, OpenAI, Replicate, etc.)
- Automatic posting to Instagram
- Scheduling
- User plans / billing
- Token systems
- Multi-provider optimization

### V2 – Productization
- Scheduling posts
- Multiple captions per post
- Provider fallback & retries
- Better UX polish
- Basic analytics
- **Optional: Gemini caption provider as a paid/optional upgrade**

### V3 – Monetization & Scale
- Token-based usage
- Paid plans
- Team / multi-account support
- Advanced analytics

## 🧠 AI Provider – ComfyUI (V1)

V1 uses **ComfyUI** as the single generation backend for both image and video.

Runtime:
- Runs locally via Docker (WSL2) with NVIDIA GPU enabled
- ComfyUI UI endpoint: http://localhost:8188

Integration Contract (Rails → ComfyUI):
- Rails submits prompt + workflow JSON via HTTP
- Rails polls job status until completion
- Rails downloads generated artifacts (image/video)
- Persist on Post:
  - prompt
  - workflow JSON
  - provider metadata
  - generated assets via ActiveStorage

Status lifecycle:
`queued → processing → generated | failed | canceled`

Notes:
- Models are stored locally and mounted into the ComfyUI container
- V1 does NOT use any external AI APIs
- Gemini integration is allowed **only in V2** (optional upgrade)

## 📚 Context7 — Mandatory Documentation Source (HARD RULE)

### Absolute Rules
- Before implementing or modifying ANY code that depends on framework behavior (Rails, Phlex, Turbo, Bootstrap, Beads),
  you MUST first check, in this order:
  1) docs/context.md (this repository)
  2) Existing code in this repository
  3) The Context7 MCP tool

- You are NOT allowed to rely on general knowledge, memory, or assumptions.

### If information is missing
- If the required information is NOT found in:
  - docs/context.md
  - the current codebase
  - or Context7
- Then you MUST:
  - STOP
  - Ask the user a concrete clarification question
- You MUST NOT invent APIs, methods, filenames, configs, commands, or behaviors.

### Evidence Requirement (MANDATORY)
- For every non-trivial implementation or decision, you MUST include a short section in your answer:

  ## Evidence
  - Source: docs/context.md (file path + section), OR
  - Source: Context7 (doc title or short snippet), OR
  - Source: Existing code (file path)

### Enforcement
- If you cannot access Context7 or cannot find the information there, you must say exactly:
  "I cannot find this in docs/context.md, the current codebase, or Context7. I need clarification."

- You MUST NOT proceed with implementation without Evidence.

## 🧠 Task Management — Beads (MANDATORY)

This repository uses **Beads (`bd`) as the single source of truth** for planning, task tracking, and agent workflow.

### 🔒 Beads Workflow Rules (STRICT)
1) **Before starting ANY work**, you MUST run:
   ```bash
   bd ready
