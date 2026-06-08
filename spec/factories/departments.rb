# frozen_string_literal: true

FactoryBot.define do
  factory :department do
    account
    sequence(:name) { |n| "Department #{n}" }
  end
end
