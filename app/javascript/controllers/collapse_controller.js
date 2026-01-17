import { Controller } from "@hotwired/stimulus"
import { Collapse } from "bootstrap"

// Connects to data-controller="collapse"
export default class extends Controller {
    static targets = ["content"]

    toggle(event) {
        event.preventDefault()
        const collapseInstance = Collapse.getOrCreateInstance(this.contentTarget)
        collapseInstance.toggle()
    }
}
