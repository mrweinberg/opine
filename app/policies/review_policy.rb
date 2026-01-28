# frozen_string_literal: true

class ReviewPolicy < ApplicationPolicy
  def create?
    user.present? && !already_reviewed?
  end

  def update?
    author?
  end

  def destroy?
    author? || user&.admin_or_above?
  end

  private

  def author?
    user.present? && record.user == user
  end

  def already_reviewed?
    record.item.reviews.exists?(user: user)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
