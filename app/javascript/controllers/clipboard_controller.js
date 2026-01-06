import { Controller } from "@hotwired/stimulus"

// data-controller="clipboard"
// data-clipboard-text-value="Caption text"
export default class extends Controller {
  static values = {
    text: String,
    copiedLabel: String
  }

  connect() {
    this.defaultLabel = this.element.textContent
  }

  async copy() {
    if (!this.textValue) return

    const copied = await this.copyToClipboard(this.textValue)
    if (copied) this.showCopied()
  }

  async copyToClipboard(text) {
    if (navigator.clipboard?.writeText) {
      try {
        await navigator.clipboard.writeText(text)
        return true
      } catch (e) {
        return this.fallbackCopy(text)
      }
    }

    return this.fallbackCopy(text)
  }

  fallbackCopy(text) {
    const textarea = document.createElement("textarea")
    textarea.value = text
    textarea.setAttribute("readonly", "")
    textarea.style.position = "absolute"
    textarea.style.left = "-9999px"
    document.body.appendChild(textarea)
    textarea.select()
    const success = document.execCommand("copy")
    textarea.remove()
    return success
  }

  showCopied() {
    const copiedLabel = this.copiedLabelValue || this.defaultLabel
    this.element.textContent = copiedLabel
    clearTimeout(this.resetTimer)
    this.resetTimer = setTimeout(() => {
      this.element.textContent = this.defaultLabel
    }, 2000)
  }
}
