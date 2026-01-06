# AI Post Maker – Authoritative Context (Context7 grounded)

## Frameworks
- Rails 8.x (no deprecated APIs)
- Ruby 3.4.x
- Phlex (NO ERB for new UI)
- Bootstrap 5 (NO Tailwind)
- Turbo / Hotwire
- Sidekiq + Redis
- ActiveStorage (local disk in V1)

## UI Rules
- New screens MUST be Phlex
- Forms MUST use bootstrap_form
- Prefer Turbo Frames / Streams
- No Tailwind utilities

## Generation Flow (V1)
- Prompt → Background Job
- Status: queued → processing → generated / failed / canceled
- One output per request
- Free providers only (AI Horde / local)

## Non-Goals (V1)
- No scheduling
- No automation
- No API posting

## Forms (MANDATORY)
- All forms MUST use `bootstrap_form` helpers:
  - `bootstrap_form_with`
  - `bootstrap_form_for` (only if required by context)
- Do NOT use `form_with` or `form_for` directly.
- Do NOT build manual `<input>` elements for app forms.
- Follow Bootstrap 5 form patterns (labels, help text, validation).

