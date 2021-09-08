class Permission < ApplicationRecord

  belongs_to :user
  belongs_to :group
  belongs_to :created_by_user, class_name: 'User'

  validates_presence_of :user_id, :group_id, :created_by_user_id
  validate :validate_group, if: :group
  validate :validate_user, if: :user
  validate :validate_organizer, if: :existed_group_and_user?

private
  def validate_group
    errors.add :group, 'Unable to add permission.' if group.archived?
  end

  def validate_user
    errors.add :user, 'Unable to add permission.' if user.archived?
  end

  def validate_organizer
    errors.add :user, 'Already added.' if group.permissions.where(user: user).exists?
  end

  def existed_group_and_user?
    group.present? and user.present?
  end
end
