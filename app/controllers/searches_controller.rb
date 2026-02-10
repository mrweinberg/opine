class SearchesController < ApplicationController
  def items
    query = params[:q].to_s.strip
    return render json: [] if query.blank?

    # Base scope
    scope = Item.all

    # Filter by subcategory/category if provided
    scope = scope.where(subcategory: params[:subcategory]) if params[:subcategory].present?

    # Search
    results = scope.search_by_name(query).limit(10)

    render json: results.map { |item|
      {
        value: item.id,
        label: item.display_label,
        name: item.name,
        identifier: item.identifier_value,
        identifier_field: item.identifier_fields.map { |f| f.to_s.humanize.titleize }.join(" / "),
        category: item.category,
        subcategory: item.subcategory
      }
    }
  end
end
