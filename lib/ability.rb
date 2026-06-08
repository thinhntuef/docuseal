# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.blank?

    common_abilities(user)

    case user.role
    when User::EDITOR_ROLE
      editor_abilities(user)
    when User::AGENT_ROLE
      agent_abilities(user)
    when User::MEMBER_ROLE
      member_abilities(user)
    when User::VIEWER_ROLE
      viewer_abilities(user)
    else
      # admin, superadmin, tenant_admin, integration and any legacy role
      # default to full access to preserve backwards compatibility.
      admin_abilities(user)
    end
  end

  private

  # Abilities granted to every authenticated user regardless of role so that
  # they can always manage their own profile, signature and personal settings.
  def common_abilities(user)
    can :manage, User, id: user.id
    can :manage, EncryptedUserConfig, user_id: user.id
    can :manage, UserConfig, user_id: user.id
    can :manage, AccessToken, user_id: user.id
    can :read, Account, id: user.account_id
  end

  def admin_abilities(user)
    can %i[read create update], Template, Abilities::TemplateConditions.collection(user) do |template|
      Abilities::TemplateConditions.entity(template, user:, ability: 'manage')
    end

    can :destroy, Template, account_id: user.account_id
    can :manage, TemplateFolder, account_id: user.account_id
    can :manage, TemplateSharing, template: { account_id: user.account_id }
    can :manage, Submission, account_id: user.account_id
    can :manage, Submitter, account_id: user.account_id
    can :manage, User, account_id: user.account_id
    can :administrate, :users
    can :manage, Department, account_id: user.account_id
    can :manage, EncryptedConfig, account_id: user.account_id
    can :manage, EncryptedUserConfig, user_id: user.id
    can :manage, AccountConfig, account_id: user.account_id
    can :manage, UserConfig, user_id: user.id
    can :manage, Account, id: user.account_id
    can :manage, AccessToken, user_id: user.id
    can :manage, WebhookUrl, account_id: user.account_id
  end

  # Editor: manages files (templates, folders, submissions), but cannot manage
  # users, departments or account-wide settings.
  def editor_abilities(user)
    can %i[read create update], Template, Abilities::TemplateConditions.collection(user) do |template|
      Abilities::TemplateConditions.entity(template, user:, ability: 'manage')
    end

    can :destroy, Template, account_id: user.account_id
    can :manage, TemplateFolder, account_id: user.account_id
    can :manage, TemplateSharing, template: { account_id: user.account_id }
    can :manage, Submission, account_id: user.account_id
    can :manage, Submitter, account_id: user.account_id
  end

  # Agent: can browse templates and send signing requests, but cannot create or
  # edit templates.
  def agent_abilities(user)
    can :read, Template, account_id: user.account_id
    can :read, TemplateFolder, account_id: user.account_id
    can %i[read create], Submission, account_id: user.account_id
    can %i[read create update], Submitter, account_id: user.account_id
  end

  # Member: read-only access limited to their own department's files.
  def member_abilities(user)
    dept_ids = department_scope_ids(user)

    can :read, Template, account_id: user.account_id, department_id: dept_ids
    can :read, TemplateFolder, account_id: user.account_id, department_id: dept_ids
    can :read, Submission, account_id: user.account_id, template: { department_id: dept_ids }
    can :read, Submitter, account_id: user.account_id, submission: { template: { department_id: dept_ids } }
  end

  # Viewer: read-only access across the whole account.
  def viewer_abilities(user)
    can :read, Template, account_id: user.account_id
    can :read, TemplateFolder, account_id: user.account_id
    can :read, Submission, account_id: user.account_id
    can :read, Submitter, account_id: user.account_id
  end

  # A member sees their own department's files plus any files that are not
  # assigned to a department (shared / account-wide).
  def department_scope_ids(user)
    [user.department_id, nil].uniq
  end
end
