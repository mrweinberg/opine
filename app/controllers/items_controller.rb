# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show, :suggest_metadata ]
  before_action :set_item, only: [ :show, :edit, :update, :destroy, :regenerate_ai ]

  def index
    @items = Item.includes(:created_by_user).order(created_at: :desc)
    @items = @items.by_category(params[:category]) if params[:category].present?
    @items = @items.by_subcategory(params[:subcategory]) if params[:subcategory].present?
  end

  def show
  end

  def suggest_metadata
    name = params[:name]
    subcategory = params[:subcategory]
    known_fields = params[:known_fields]&.to_unsafe_h || {}

    suggestions = AiMetadataService.new.suggest_metadata(
      name: name,
      subcategory: subcategory,
      known_fields: known_fields
    )

    render json: { suggestions: suggestions || {} }
  end

  def new
    @item = Item.new
  end

  def create
    @item = current_user.items.build(item_params)

    # Assign current user to any nested reviews
    @item.reviews.each { |review| review.user = current_user }

    if @item.save
      redirect_to @item, notice: "Item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @item
  end

  def update
    authorize @item

    if @item.update(item_params)
      redirect_to @item, notice: "Item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @item
    @item.destroy
    redirect_to items_path, notice: "Item was successfully deleted."
  end

  def regenerate_ai
    authorize @item
    @item.update_columns(ai_summary: nil, ai_estimated_score: nil, ai_last_updated_at: nil)
    AiItemEnrichmentJob.perform_later(@item.id)
    redirect_to @item, notice: "AI summary is being regenerated…"
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :category, :subcategory, metadata: {}, reviews_attributes: [ :score, :body, images: [] ])
  end
end
