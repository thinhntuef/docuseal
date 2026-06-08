# frozen_string_literal: true

require 'cancan/matchers'

describe Ability do
  let(:account) { create(:account) }
  let(:department) { create(:department, account:) }

  describe 'admin role' do
    subject(:ability) { described_class.new(user) }

    let(:user) { create(:user, account:, role: User::ADMIN_ROLE) }

    it 'can administrate users and departments' do
      expect(ability).to be_able_to(:administrate, :users)
      expect(ability).to be_able_to(:manage, build(:user, account:))
      expect(ability).to be_able_to(:manage, department)
    end

    it 'can manage templates' do
      expect(ability).to be_able_to(:create, build(:template, account:))
      expect(ability).to be_able_to(:destroy, build(:template, account:))
    end
  end

  describe 'editor role' do
    subject(:ability) { described_class.new(user) }

    let(:user) { create(:user, account:, role: User::EDITOR_ROLE) }

    it 'manages files but not users or departments' do
      expect(ability).to be_able_to(:create, build(:template, account:))
      expect(ability).to be_able_to(:manage, build(:submission, account:))
      expect(ability).not_to be_able_to(:administrate, :users)
      expect(ability).not_to be_able_to(:manage, build(:user, account:))
      expect(ability).not_to be_able_to(:manage, department)
    end

    it 'can manage its own profile' do
      expect(ability).to be_able_to(:manage, user)
    end
  end

  describe 'agent role' do
    subject(:ability) { described_class.new(user) }

    let(:user) { create(:user, account:, role: User::AGENT_ROLE) }

    it 'can send signing requests but not edit templates' do
      expect(ability).to be_able_to(:read, build(:template, account:))
      expect(ability).to be_able_to(:create, build(:submission, account:))
      expect(ability).not_to be_able_to(:create, build(:template, account:))
      expect(ability).not_to be_able_to(:update, build(:template, account:))
    end
  end

  describe 'member role' do
    subject(:ability) { described_class.new(user) }

    let(:user) { create(:user, account:, role: User::MEMBER_ROLE, department:) }

    it 'reads templates that belong to its own department' do
      expect(ability).to be_able_to(:read, build(:template, account:, department:))
    end

    it 'cannot read templates of other departments' do
      other_department = create(:department, account:)

      expect(ability).not_to be_able_to(:read, build(:template, account:, department: other_department))
    end

    it 'cannot create or edit templates' do
      expect(ability).not_to be_able_to(:create, build(:template, account:, department:))
      expect(ability).not_to be_able_to(:update, build(:template, account:, department:))
    end
  end

  describe 'viewer role' do
    subject(:ability) { described_class.new(user) }

    let(:user) { create(:user, account:, role: User::VIEWER_ROLE) }

    it 'has read-only access across the account' do
      expect(ability).to be_able_to(:read, build(:template, account:))
      expect(ability).to be_able_to(:read, build(:submission, account:))
      expect(ability).not_to be_able_to(:create, build(:template, account:))
      expect(ability).not_to be_able_to(:create, build(:submission, account:))
    end
  end
end
