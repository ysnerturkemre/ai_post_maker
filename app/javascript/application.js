// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Custom Turbo Stream action for delayed redirects (used after login).
// Usage: <turbo-stream action="redirect" url="/home" delay="3000"></turbo-stream>
Turbo.StreamActions.redirect = function () {
  const url = this.getAttribute("url")
  const delay = parseInt(this.getAttribute("delay"), 10) || 0

  if (!url) return

  setTimeout(() => {
    if (window.Turbo) {
      Turbo.visit(url, { action: "replace" })
    } else {
      window.location.href = url
    }
  }, delay)
}

// Auto-dismiss flash/alert elements marked with data-auto-dismiss.
const autoDismissFlash = () => {
  const flashes = document.querySelectorAll("[data-auto-dismiss='true']")
  flashes.forEach((el) => {
    if (el.dataset.autoDismissArmed) return
    el.dataset.autoDismissArmed = "1"

    const delay = parseInt(el.dataset.delay, 10)
    const timeoutMs = Number.isFinite(delay) ? delay : 3000

    setTimeout(() => {
      el.style.transition = "opacity 0.4s ease, transform 0.4s ease"
      el.style.opacity = "0"
      el.style.transform = "translateY(-6px)"
      setTimeout(() => el.remove(), 400)
    }, timeoutMs)
  })
}

document.addEventListener("DOMContentLoaded", autoDismissFlash)
document.addEventListener("turbo:load", autoDismissFlash)
document.addEventListener("turbo:render", autoDismissFlash)
document.addEventListener("turbo:frame-render", autoDismissFlash)
document.addEventListener("turbo:before-stream-render", (event) => {
  const render = event.detail.render
  event.detail.render = (streamElement) => {
    render(streamElement)
    autoDismissFlash()
  }
})

// Flash messages inside auth forms
const setupFlashMessages = () => {
  const flashes = document.querySelectorAll(".flash-message[data-dismissing='true']")
  flashes.forEach((el) => {
    if (el.dataset.bound) return
    el.dataset.bound = "1"
    setTimeout(() => {
      el.style.transition = "opacity 0.6s ease"
      el.style.opacity = "0"
      setTimeout(() => el.remove(), 600)
    }, 4000)
  })
}

const flashCloseHandler = (e) => {
  if (!e.target.matches(".flash-message .btn-close")) return
  const fm = e.target.closest(".flash-message")
  if (!fm) return
  fm.style.transition = "opacity 0.4s ease"
  fm.style.opacity = "0"
  setTimeout(() => fm.remove(), 400)
}

document.addEventListener("DOMContentLoaded", setupFlashMessages)
document.addEventListener("turbo:load", setupFlashMessages)
document.addEventListener("turbo:render", setupFlashMessages)
document.addEventListener("turbo:frame-render", setupFlashMessages)
document.addEventListener("click", flashCloseHandler)

// Turbo Stream action: remove_after
Turbo.StreamActions.remove_after = function () {
  const delay = parseInt(this.getAttribute("delay"), 10) || 0
  const targetId = this.getAttribute("target")
  if (!targetId) return

  const removeTargets = () => {
    // target can be id (without #) per turbo_stream_action_tag semantics
    const selector = `#${targetId.replace(/^#/, "")}`
    document.querySelectorAll(selector).forEach((el) => el.remove())
  }

  setTimeout(removeTargets, delay)
}
