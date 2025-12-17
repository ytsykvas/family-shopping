import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = {
    url: String,
    debounce: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  search() {
    // Clear previous timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    const query = this.inputTarget.value.trim()

    // If query is empty, clear results
    if (query === "") {
      this.clearResults()
      return
    }

    // Debounce the search
    this.timeout = setTimeout(() => {
      this.performSearch(query)
    }, this.debounceValue)
  }

  async performSearch(query) {
    // Fetch search results
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("query", query)

    try {
      const response = await fetch(url, {
        method: "GET",
        headers: {
          "Accept": "text/html",
          "X-CSRF-Token": this.getCSRFToken()
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const html = await response.text()
      
      if (this.hasResultsTarget) {
        // Extract results from the response HTML
        const parser = new DOMParser()
        const doc = parser.parseFromString(html, "text/html")
        const resultsElement = doc.querySelector("#user-search-results")
        
        if (resultsElement) {
          this.resultsTarget.innerHTML = resultsElement.innerHTML
        } else {
          // If no results element found, try to find search results directly
          const searchResults = doc.querySelector(".search-results, .no-results")
          if (searchResults) {
            this.resultsTarget.innerHTML = searchResults.outerHTML
          }
        }
      }
    } catch (error) {
      console.error("Error searching users:", error)
    }
  }

  clearResults() {
    // Clear results directly without server request
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = ""
    }
  }

  getCSRFToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ""
  }
}

