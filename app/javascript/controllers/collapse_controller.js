import { Controller } from "@hotwired/stimulus"
import { Collapse } from "bootstrap"

// Connects to data-controller="collapse"
export default class extends Controller {
    static targets = ["content"]

    toggle(event) {
        event.preventDefault()
        const collapseInstance = Collapse.getOrCreateInstance(this.contentTarget)
        collapseInstance.toggle()

        // Toggle button text
        const button = event.currentTarget
        const toggleText = button.querySelector('.toggle-text')
        if (toggleText) {
            const isExpanded = this.contentTarget.classList.contains('show')
            toggleText.textContent = isExpanded ? button.dataset.showText : button.dataset.hideText
        }
    }
}
