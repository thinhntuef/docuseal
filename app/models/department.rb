# frozen_string_literal: true

# == Schema Information
#
# Table name: departments
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  uuid       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#
# Indexes
#
#  index_departments_on_account_id           (account_id)
#  index_departments_on_account_id_and_name  (account_id,name) UNIQUE
#  index_departments_on_uuid                 (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Department < ApplicationRecord
  belongs_to :account

  has_many :users, dependent: :nullify
  has_many :templates, dependent: :nullify
  has_many :template_folders, dependent: :nullify

  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  validates :name, presence: true, uniqueness: { scope: :account_id, case_sensitive: false }

  scope :ordered, -> { order(name: :asc) }
end
