# frozen_string_literal: true

class ItemPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    user.present?
  end

  def update?
    owner_or_admin?
  end

  def destroy?
    return false unless owner_or_admin?
    # Regular users can only delete items with no reviews
    return true if user.admin_or_above?

    record.reviews_count.zero?
  end

  def regenerate_ai?
    user.present? && user.admin_or_above?
  end

  private

  def owner_or_admin?
    user.present? && (record.created_by_user == user || user.admin_or_above?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
