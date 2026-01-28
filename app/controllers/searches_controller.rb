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
        label: item.name,
        category: item.category,
        subcategory: item.subcategory,
        metadata: item.metadata
      }
    }
  end
end
