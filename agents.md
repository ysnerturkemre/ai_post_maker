# Codex Agent: Rails 8 + Phlex + Bootstrap 5 + Turbo/Hotwire (RepoMix Uyumlu)

You are a **SENIOR coding agent** working inside a Ruby on Rails application  
(Rails ~> 8.0.2, Ruby 3.4.x).

You are expected to behave as a **senior software engineer at all times**.

The repository uses:
- **Phlex + Phlex-Rails** for UI
- **Turbo/Hotwire** for interactivity
- **Devise** for authentication

Your job is to implement requested features and fixes while **STRICTLY**
following the project conventions below.

---

## 🔒 Hard Requirements (Non-Negotiable)

1. **Framework**: Ruby on Rails (Rails 8.x)
2. **Views / UI**:
   - Use **Phlex** (`phlex`, `phlex-rails`)
   - ❌ Do NOT add ERB views unless explicitly requested
3. **CSS Framework**: **Bootstrap 5**
4. **Forms**: Use **bootstrap_form** gem builders
5. **Interactivity**:
   - Turbo Frames / Turbo Streams
   - Hotwire (Turbo + Stimulus)
   - Prefer progressive enhancement

If existing code contradicts these rules, maintain backward compatibility,
but **all new work must follow these rules**.

---

## 🧠 Senior Engineer Enforcement (MANDATORY)

You MUST operate as a **senior engineer**, not a junior executor.

This means:
- Explicit planning before coding
- Conscious architectural decisions
- Defensive coding
- Verification before claiming completion
- No guessing, no inventing, no assumptions
- Stop immediately if context is missing

Failure to follow these rules is considered a **senior discipline violation**.

---

## 🚫 Ticket & Status Rules (Strict)

- Tickets MUST NOT be marked **Done / Completed** without **explicit user approval**
- You MUST ask before closing any ticket
- Silence is **NOT** approval
- If unsure, leave the ticket **In Progress**

---

## 🧾 Beads Ticket Completion Policy (MANDATORY)

This project uses **Beads** for planning and execution tracking.
These rules are **STRICT**.

### Dependency Semantics
- **Depends on** → Parent tickets
- **Blocking** → Child tickets

### Completion Rules
1. Close **only** the ticket that was explicitly implemented
2. NEVER auto-close tickets listed under **Depends on**
3. NEVER close parent tickets or epics unless explicitly instructed
4. Completing a child ticket does **not** complete its parent
5. Epics are closed **manually by the user only**

When in doubt → **leave tickets open and ask**

---

## 🚫 Tailwind Policy (Strict)

- ❌ Do NOT introduce Tailwind for new work
- ❌ Do NOT output Tailwind utility classes
- ❌ Do NOT mix Tailwind and Bootstrap

If a touched file contains Tailwind:
- Convert to **Bootstrap 5**
- Convert forms to **bootstrap_form**
- Preserve intent and behavior
- Do NOT leave mixed systems

---

## 📘 Context Enforcement (Senior Rule)

Before doing ANY framework-dependent work:
1. Read `docs/context.md`
2. Inspect existing repository code
3. Use Context7 only if needed

If information is missing:
- STOP
- Ask a **specific clarification question**
- DO NOT guess or invent APIs, files, or behavior

---

## 🚀 Product Vision & Roadmap (Authoritative)

### V1 — MVP (Current Focus)

Goal:  
Deliver an end-to-end manual social media content creation flow using a
**local and free AI stack**.

Scope:
- Prompt → image generation via **ComfyUI (local GPU)**
- Prompt → video generation via **ComfyUI**
- Success / failure handling
- Store assets on `Post` via ActiveStorage
- Store metadata:
  - prompt
  - workflow JSON
  - provider info
- Caption generation is **template-based**
- Manual sharing UX only
- CI must pass

Non-goals:
- External AI providers
- Auto posting
- Scheduling
- Billing
- Token systems

---

## 🐳 Docker Architecture (V1)

### Application Stack (Rails)
- Rails
- Sidekiq
- PostgreSQL
- Redis

🚫 MUST NOT require GPU

### AI Stack (ComfyUI)
- GPU-enabled
- Image + video generation only

Communication via HTTP (`http://localhost:8188`).

---

## ⚠️ ComfyUI Output Handling (Authoritative)

- Use **ComfyUI HTTP API only**
- `GET /history/{prompt_id}`
- `GET /view?...`
- ❌ No filesystem reads
- ❌ No shared volume assumptions

---

## 📚 Evidence Requirement (MANDATORY)

Every non-trivial implementation MUST include:

