import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "container", "hiddenContainer", "addButton"]
  static values = { existing: { type: Array, default: [] } }

  connect() {
    this.tags = [...this.existingValue]
    this.render()
  }

  handleKeydown(event) {
    if (event.key === "Enter" || event.key === ",") {
      event.preventDefault()
      this.addTag()
    }
  }

  addTag() {
    const value = this.inputTarget.value.trim().toLowerCase().slice(0, 20)
    if (!value || this.tags.length >= 5 || this.tags.includes(value)) {
      this.inputTarget.value = ""
      return
    }

    this.tags.push(value)
    this.inputTarget.value = ""
    this.render()
  }

  removeTag(event) {
    const tag = event.currentTarget.dataset.tag
    this.tags = this.tags.filter(t => t !== tag)
    this.render()
  }

  render() {
    // Render pills
    this.containerTarget.innerHTML = this.tags.map(tag => `
      <span class="inline-flex items-center gap-1 bg-parchment text-walnut text-xs px-2 py-0.5 rounded-full border border-sand">
        ${this.escapeHtml(tag)}
        <button type="button" data-action="click->tag-input#removeTag" data-tag="${this.escapeHtml(tag)}"
                class="text-walnut/50 hover:text-terracotta font-bold leading-none">&times;</button>
      </span>
    `).join("")

    // Render hidden inputs
    this.hiddenContainerTarget.innerHTML = this.tags.map(tag =>
      `<input type="hidden" name="review[tags][]" value="${this.escapeHtml(tag)}">`
    ).join("")

    // Disable input and button when max reached
    const maxReached = this.tags.length >= 5
    this.inputTarget.disabled = maxReached
    this.inputTarget.placeholder = maxReached ? "Maximum 5 tags reached" : "Type a tag..."

    if (this.hasAddButtonTarget) {
      this.addButtonTarget.disabled = maxReached
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
