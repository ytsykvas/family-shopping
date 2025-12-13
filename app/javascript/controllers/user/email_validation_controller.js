import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "feedback"]
  static values = {
    url: String,
    debounce: { type: Number, default: 500 }
  }

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  validate() {
    // Clear previous timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    const email = this.inputTarget.value.trim()

    // Clear feedback if empty
    if (email === "") {
      this.clearFeedback()
      return
    }

    // Debounce the API call
    this.timeout = setTimeout(() => {
      this.checkEmail(email)
    }, this.debounceValue)
  }

  async checkEmail(email) {
    try {
      const response = await fetch(`${this.urlValue}?email=${encodeURIComponent(email)}`, {
        method: "GET",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": this.getCSRFToken()
        }
      })

      if (!response.ok) {
        throw new Error("Network response was not ok")
      }

      const data = await response.json()
      this.updateFeedback(data.available, data.message)
    } catch (error) {
      console.error("Error checking email:", error)
    }
  }

  updateFeedback(available, message) {
    if (!this.hasFeedbackTarget) return

    this.feedbackTarget.textContent = message
    this.feedbackTarget.classList.remove("d-none", "text-success", "text-danger")
    
    if (available) {
      this.feedbackTarget.classList.add("text-success")
      this.inputTarget.classList.remove("is-invalid")
      this.inputTarget.classList.add("is-valid")
    } else {
      this.feedbackTarget.classList.add("text-danger")
      this.inputTarget.classList.remove("is-valid")
      this.inputTarget.classList.add("is-invalid")
    }
  }

  clearFeedback() {
    if (!this.hasFeedbackTarget) return

    this.feedbackTarget.textContent = ""
    this.feedbackTarget.classList.add("d-none")
    this.inputTarget.classList.remove("is-valid", "is-invalid")
  }

  getCSRFToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ""
  }
}
