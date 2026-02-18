import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  close(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.menuTarget.classList.add("hidden")
    }
  }

  connect() {
    this.boundClose = this.close.bind(this)
    this.boundEscape = this.closeOnEscape.bind(this)
    document.addEventListener("click", this.boundClose)
    document.addEventListener("keydown", this.boundEscape)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClose)
    document.removeEventListener("keydown", this.boundEscape)
  }
}
