# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item
  before_action :set_review, only: [ :edit, :update, :destroy ]

  def create
    @review = @item.reviews.build(review_params)
    @review.user = current_user

    authorize @review

    respond_to do |format|
      if @review.save
        format.turbo_stream
        format.html { redirect_to @item, notice: "Review posted!" }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_review_form", partial: "reviews/form", locals: { item: @item, review: @review }) }
        format.html { redirect_to @item, alert: @review.errors.full_messages.join(", ") }
      end
    end
  end

  def edit
    authorize @review
  end

  def update
    authorize @review

    respond_to do |format|
      if @review.update(review_params)
        format.turbo_stream
        format.html { redirect_to @item, notice: "Review updated!" }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @review
    @review.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @item, notice: "Review deleted." }
    end
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def set_review
    @review = @item.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:score, :body, images: [])
  end
end
