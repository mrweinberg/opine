import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "step1", "step2", "step3",
        "subcategorySelect",
        "searchInput", "searchResults",
        "existingItemForm", "newItemForm",
        "itemFields", "itemNameInput",
        "metadataContainer"
    ]
    static values = {
        categoryMap: Object,
        attributeDefinitions: Object
    }

    connect() {
        this.showStep(1)
    }

    // Step 1: Subcategory Selection
    selectSubcategory(event) {
        const subcategory = event.target.value
        if (!subcategory) return

        this.currentSubcategory = subcategory
        this.showStep(2)
        // Focus search input
        setTimeout(() => this.searchInputTarget.focus(), 100)
    }

    // Step 2: Search Logic
    search() {
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
            this.performSearch()
        }, 300)
    }

    async performSearch() {
        const query = this.searchInputTarget.value.trim()
        if (query.length < 2) {
            this.searchResultsTarget.innerHTML = ""
            this.searchResultsTarget.classList.add("hidden")
            return
        }

        const response = await fetch(`/search/items?q=${encodeURIComponent(query)}&subcategory=${encodeURIComponent(this.currentSubcategory)}`)
        const items = await response.json()

        this.renderResults(items, query)
    }

    renderResults(items, query) {
        this.searchResultsTarget.classList.remove("hidden")

        let html = items.map(item => `
      <div class="p-3 hover:bg-gray-50 cursor-pointer border-b last:border-0"
           data-action="click->review-flow#selectExistingItem"
           data-item-id="${item.value}"
           data-item-name="${item.label}">
        <div class="font-medium text-gray-900">${item.label}</div>
        <div class="text-xs text-gray-500">${item.metadata?.city || item.metadata?.producer || ''}</div>
      </div>
    `).join("")

        // "Create new" option
        html += `
      <div class="p-3 hover:bg-blue-50 cursor-pointer text-blue-700 font-medium border-t"
           data-action="click->review-flow#selectNewItem">
        + Create "${query}" as new item
      </div>
    `

        this.searchResultsTarget.innerHTML = html
    }

    // Step 3: Branching paths

    selectExistingItem(event) {
        const itemEl = event.currentTarget
        const itemId = itemEl.dataset.itemId
        const itemName = itemEl.dataset.itemName

        // Populate Existing Item Form
        const form = this.existingItemFormTarget.querySelector("form")
        form.action = `/items/${itemId}/reviews`

        // Show form container
        this.existingItemFormTarget.classList.remove("hidden")
        this.newItemFormTarget.classList.add("hidden")

        this.showStep(3)
    }

    selectNewItem() {
        const query = this.searchInputTarget.value.trim()

        // Populate New Item Form
        this.newItemFormTarget.classList.remove("hidden")
        this.existingItemFormTarget.classList.add("hidden")

        // Set fixed fields
        const nameInput = this.newItemFormTarget.querySelector("input[name='item[name]']")
        const categoryInput = this.newItemFormTarget.querySelector("input[name='item[category]']")
        const subcategoryInput = this.newItemFormTarget.querySelector("input[name='item[subcategory]']")

        nameInput.value = query
        subcategoryInput.value = this.currentSubcategory
        // Find category from subcategory map
        const category = Object.keys(this.categoryMapValue).find(cat =>
            this.categoryMapValue[cat].includes(this.currentSubcategory)
        )
        categoryInput.value = category

        // Render metadata fields
        this.renderMetadataFields(this.currentSubcategory)

        this.showStep(3)
    }

    renderMetadataFields(subcategory) {
        const container = this.metadataContainerTarget
        container.innerHTML = ""

        const attributes = this.attributeDefinitionsValue[subcategory] || []

        attributes.forEach(attr => {
            const wrapper = document.createElement("div")
            wrapper.innerHTML = `
        <label class="block text-sm font-medium text-gray-700 mb-1 capitalize">${attr.replace(/_/g, ' ')}</label>
        <input type="text" name="item[metadata][${attr}]" 
               class="w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
      `
            container.appendChild(wrapper)
        })
    }

    showStep(stepNumber) {
        [this.step1Target, this.step2Target, this.step3Target].forEach((el, index) => {
            if (index + 1 === stepNumber) {
                el.classList.remove("hidden")
            } else {
                el.classList.add("hidden")
            }
        })
    }
}
