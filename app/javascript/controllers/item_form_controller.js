import { Controller } from "@hotwired/stimulus"

// Handles dynamic category → subcategory filtering and metadata field rendering
export default class extends Controller {
    static targets = ["category", "subcategory", "metadataFields"]
    static values = {
        categoryMap: Object,
        attributeDefinitions: Object,
        identifierFields: Object,
        existingMetadata: Object
    }

    connect() {
        this.updateSubcategories()
    }

    updateSubcategories() {
        const category = this.categoryTarget.value
        const subcategorySelect = this.subcategoryTarget
        const currentValue = subcategorySelect.value

        // Clear existing options
        subcategorySelect.innerHTML = '<option value="">Select subcategory...</option>'

        if (category && this.categoryMapValue[category]) {
            const subcategories = this.categoryMapValue[category]
            subcategories.forEach(subcat => {
                const option = document.createElement("option")
                option.value = subcat
                option.textContent = subcat
                if (subcat === currentValue) option.selected = true
                subcategorySelect.appendChild(option)
            })
        }

        this.updateMetadataFields()
    }

    updateMetadataFields() {
        const subcategory = this.subcategoryTarget.value
        const container = this.metadataFieldsTarget

        // Clear existing fields
        container.innerHTML = ""

        if (!subcategory || !this.attributeDefinitionsValue[subcategory]) {
            container.classList.add("hidden")
            return
        }

        container.classList.remove("hidden")
        const attributes = this.attributeDefinitionsValue[subcategory]

        const identifierAttrs = [].concat(this.identifierFieldsValue[subcategory] || [])

        attributes.forEach(attr => {
            const fieldName = this.humanize(attr)
            const inputName = `item[metadata][${attr}]`
            const inputId = `item_metadata_${attr}`
            const isIdentifier = identifierAttrs.includes(attr)
            const starHtml = isIdentifier ? ' <span class="text-terracotta">★</span>' : ''
            const existingValue = this.existingMetadataValue[attr] || ''

            const wrapper = document.createElement("div")
            wrapper.innerHTML = `
        <label for="${inputId}" class="block text-sm font-medium text-walnut mb-1">${fieldName}${starHtml}</label>
        <input type="text" 
               name="${inputName}" 
               id="${inputId}"
               value="${this.escapeAttr(existingValue)}"
               class="w-full rounded-lg border border-sand bg-warm-white shadow-sm focus:outline-none focus:border-clay focus:ring-2 focus:ring-clay/40${isIdentifier ? ' ring-2 ring-clay/30' : ''}"
               placeholder="Enter ${fieldName.toLowerCase()}...">
      `
            container.appendChild(wrapper)
        })
    }

    escapeAttr(str) {
        return str.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    }

    humanize(str) {
        return str
            .replace(/_/g, " ")
            .replace(/\b\w/g, char => char.toUpperCase())
    }
}
