import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "step1", "step2", "step3", "step4",
        "categoryLabel", "subcategoryLabel",
        "subcategoryButtons",
        "searchInput", "searchResults",
        "existingItemForm", "existingItemHeader", "newItemForm",
        "itemFields", "metadataContainer"
    ]
    static values = {
        categoryMap: Object,
        attributeDefinitions: Object,
        identifierFields: Object
    }

    connect() {
        this.goToStep(1)
    }

    // Step 1: Category Selection
    selectCategory(event) {
        const category = event.currentTarget.value
        if (!category) return

        this.currentCategory = category

        // Render subcategory buttons
        const subcategories = this.categoryMapValue[category] || []
        this.categoryLabelTarget.textContent = category.toLowerCase()
        this.subcategoryButtonsTarget.innerHTML = subcategories.map(sub => `
            <button type="button"
                    class="p-4 border-2 border-sand rounded-xl hover:border-clay hover:bg-parchment text-left transition"
                    data-action="click->review-flow#selectSubcategory"
                    value="${sub}">
                <span class="font-medium text-espresso block pointer-events-none">${sub}</span>
            </button>
        `).join("")

        this.goToStep(2)
    }

    // Step 2: Subcategory Selection
    selectSubcategory(event) {
        const subcategory = event.currentTarget.value
        if (!subcategory) return

        this.currentSubcategory = subcategory
        this.subcategoryLabelTarget.textContent = subcategory.toLowerCase()

        // Clear search
        this.searchInputTarget.value = ""
        this.searchResultsTarget.innerHTML = ""
        this.searchResultsTarget.classList.add("hidden")

        this.goToStep(3)
        setTimeout(() => this.searchInputTarget.focus(), 100)
    }

    // Step 3: Search Logic
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

        let html = items.map(item => {
            const identifierHtml = item.identifier
                ? `<div class="text-xs text-walnut/70">${item.identifier_field}: ${item.identifier}</div>`
                : ''
            return `
      <div class="p-3 hover:bg-parchment cursor-pointer border-b border-sand last:border-0"
           data-action="click->review-flow#selectExistingItem"
           data-item-id="${item.value}"
           data-item-name="${item.label}">
        <div class="font-medium text-espresso">${item.label}</div>
        ${identifierHtml}
      </div>
    `
        }).join("")

        // "Create new" option
        html += `
      <div class="p-3 hover:bg-parchment cursor-pointer text-clay font-medium border-t border-sand"
           data-action="click->review-flow#selectNewItem">
        + Create "${this.escapeHtml(query)}" as new ${this.currentSubcategory}
      </div>
    `

        this.searchResultsTarget.innerHTML = html
    }

    // Step 4: Branching paths

    selectExistingItem(event) {
        const itemEl = event.currentTarget
        const itemId = itemEl.dataset.itemId
        const itemName = itemEl.dataset.itemName

        // Populate Existing Item Form
        const form = this.existingItemFormTarget.querySelector("form")
        form.action = `/items/${itemId}/reviews`

        // Show item name in header
        this.existingItemHeaderTarget.innerHTML = `
            <h2 class="text-xl font-bold text-gray-900">${this.escapeHtml(itemName)}</h2>
            <div class="text-sm text-gray-500 mt-1">${this.currentCategory} › ${this.currentSubcategory}</div>
        `

        // Show form container
        this.existingItemFormTarget.classList.remove("hidden")
        this.newItemFormTarget.classList.add("hidden")

        this.goToStep(4)
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
        categoryInput.value = this.currentCategory
        subcategoryInput.value = this.currentSubcategory

        // Render metadata fields
        this.renderMetadataFields(this.currentSubcategory)

        this.goToStep(4)
    }

    renderMetadataFields(subcategory) {
        const container = this.metadataContainerTarget
        container.innerHTML = ""

        const attributes = this.attributeDefinitionsValue[subcategory] || []
        const identifierAttrs = [].concat(this.identifierFieldsValue[subcategory] || [])

        attributes.forEach(attr => {
            const isIdentifier = identifierAttrs.includes(attr)
            const starHtml = isIdentifier ? ' <span class="text-terracotta">★</span>' : ''
            const wrapper = document.createElement("div")
            wrapper.innerHTML = `
        <label class="block text-sm font-medium text-walnut mb-1 capitalize">${attr.replace(/_/g, ' ')}${starHtml}</label>
        <input type="text" name="item[metadata][${attr}]" 
               class="w-full rounded-lg border border-sand bg-warm-white shadow-sm focus:outline-none focus:border-clay focus:ring-2 focus:ring-clay/40${isIdentifier ? ' ring-2 ring-clay/30' : ''}">
      `
            container.appendChild(wrapper)
        })
    }

    goToStep(stepOrEvent) {
        const stepNumber = typeof stepOrEvent === 'number'
            ? stepOrEvent
            : parseInt(stepOrEvent.params?.step || stepOrEvent)

        const steps = [this.step1Target, this.step2Target, this.step3Target, this.step4Target]
        steps.forEach((el, index) => {
            if (index + 1 === stepNumber) {
                el.classList.remove("hidden")
            } else {
                el.classList.add("hidden")
            }
        })
    }

    escapeHtml(text) {
        const div = document.createElement('div')
        div.textContent = text
        return div.innerHTML
    }
}
