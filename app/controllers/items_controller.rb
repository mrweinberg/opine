# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_item, only: [ :show, :edit, :update, :destroy ]

  def index
    @items = Item.includes(:created_by_user).order(created_at: :desc)
    @items = @items.by_category(params[:category]) if params[:category].present?
    @items = @items.by_subcategory(params[:subcategory]) if params[:subcategory].present?
  end

  def show
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

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :category, :subcategory, metadata: {}, reviews_attributes: [ :score, :body, images: [] ])
  end
end
