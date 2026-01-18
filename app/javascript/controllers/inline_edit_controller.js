import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["view", "form", "input"]

    connect() {
        // Optional: focus input when form appears?
    }

    toggle(e) {
        e.preventDefault()
        this.viewTarget.classList.toggle("d-none")
        this.formTarget.classList.toggle("d-none")

        if (!this.formTarget.classList.contains("d-none")) {
            this.inputTarget.focus()
        }
    }
}
