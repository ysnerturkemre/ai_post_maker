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

  shareInstagram(event) {
    this.stopAndPrevent(event)
    this.openExternal("instagram")
  }

  shareTikTok(event) {
    this.stopAndPrevent(event)

    this.copySharePayloadToClipboard()
    this.openExternal("tiktok")
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

  openExternal(platform) {
    const destination = this.platformShareUrl(platform)
    if (!destination) return

    window.open(destination, "_blank", "noopener")
  }

  platformShareUrl(platform) {
    const url = encodeURIComponent(this.urlValue || "")
    if (!url) return null

    if (platform === "instagram") {
      return `https://www.instagram.com/?url=${url}`
    }

    if (platform === "tiktok") {
      return "https://www.tiktok.com/upload"
    }

    return null
  }

  copySharePayloadToClipboard() {
    if (!navigator.clipboard?.writeText) return

    const lines = [this.textValue || "", this.urlValue || ""].filter(Boolean)
    if (lines.length === 0) return

    navigator.clipboard.writeText(lines.join("\n\n")).catch(() => {})
  }
}
