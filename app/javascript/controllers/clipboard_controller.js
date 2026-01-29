import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    text: String,
    copiedText: String
  }

  connect() {
    // console.log("Clipboard controller connected")
  }

  copy(event) {
    event.preventDefault()

    // Copy to clipboard
    navigator.clipboard.writeText(this.textValue).then(() => {
      // Optional: Add visual feedback
      const originalText = this.element.innerHTML
      const copiedText = this.hasCopiedTextValue ? this.copiedTextValue : '<i class="bi bi-check2 me-2"></i>Copied!'
      this.element.innerHTML = copiedText

      setTimeout(() => {
        this.element.innerHTML = originalText
      }, 2000)
    }).catch(err => {
      console.error('Failed to copy text: ', err)
    })
  }
}
