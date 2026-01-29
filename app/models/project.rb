class Project < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships, source: :user

  validates :name, presence: true

  def editable_by?(user)
    owner_id == user.id || user.admin?
  end
end
