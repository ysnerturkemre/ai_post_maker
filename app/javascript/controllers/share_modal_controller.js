import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  static values = {
    title: String,
    text: String,
    url: String
  }

  open(event) {
    this.stopAndPrevent(event)
    if (!this.hasModalTarget) return

    this.modalTarget.hidden = false
    document.body.classList.add("share-modal-open")
  }

  close(event) {
    this.stopAndPrevent(event)
    this.hideModal()
  }

  closeFromBackdrop(event) {
    this.stopAndPrevent(event)
    if (event.target !== event.currentTarget) return

    this.hideModal()
  }

  shareX(event) {
    this.stopAndPrevent(event)
    const text = encodeURIComponent(this.textValue || "")
    const url = encodeURIComponent(this.urlValue || "")
    window.open(`https://twitter.com/intent/tweet?text=${text}&url=${url}`, "_blank", "noopener")
  }

  shareReddit(event) {
    this.stopAndPrevent(event)
    const title = encodeURIComponent(this.titleValue || "")
    const url = encodeURIComponent(this.urlValue || "")
    window.open(`https://www.reddit.com/submit?url=${url}&title=${title}`, "_blank", "noopener")
  }

  fallback(event) {
    this.stopAndPrevent(event)
    const url = event.currentTarget.dataset.url
    if (!url) return

    if (window.Turbo) {
      window.Turbo.visit(url)
    } else {
      window.location.href = url
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  hideModal() {
    if (this.hasModalTarget) {
      this.modalTarget.hidden = true
    }
    document.body.classList.remove("share-modal-open")
  }

  stopAndPrevent(event) {
    event.preventDefault()
    event.stopPropagation()
  }
}
