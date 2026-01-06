import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// data-controller="poller"
// data-poller-url-value="/home/recent_panel"
// data-poller-interval-value="5" (seconds)
export default class extends Controller {
  static values = {
    url: String,
    interval: { type: Number, default: 5 }
  }

  connect() {
    this.start()
  }

  disconnect() {
    this.stop()
  }

  start() {
    this.stop()
    const ms = Math.max(2, this.intervalValue) * 1000
    this.timer = setInterval(() => this.refresh(), ms)
  }

  stop() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }

  async refresh() {
    if (!this.urlValue) return

    try {
      const response = await fetch(this.urlValue, {
        headers: { Accept: "text/vnd.turbo-stream.html", "Cache-Control": "no-store" }
      })

      if (!response.ok) return
      const html = await response.text()
      Turbo.renderStreamMessage(html)
    } catch (e) {
      // swallow; transient network errors are fine
    }
  }
}
