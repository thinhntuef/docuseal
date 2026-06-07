# frozen_string_literal: true

class SsoSettingsController < ApplicationController
  before_action :load_encrypted_config
  authorize_resource :encrypted_config, only: :index

  SAML_PARAMS = %i[
    enabled
    idp_sso_url
    idp_entity_id
    idp_cert
    sp_entity_id
    name_identifier_format
    email_attribute
    first_name_attribute
    last_name_attribute
    role_attribute
    department_attribute
    default_role
    auto_provision
  ].freeze

  def index; end

  def create
    authorize!(:manage, @encrypted_config)

    @encrypted_config.value = saml_params.to_h

    if @encrypted_config.save
      redirect_to settings_sso_index_path, notice: I18n.t('sso_settings_have_been_saved')
    else
      render :index, status: :unprocessable_content
    end
  end

  private

  def saml_params
    params.require(:saml_configs).permit(*SAML_PARAMS)
  end

  def load_encrypted_config
    @encrypted_config =
      EncryptedConfig.find_or_initialize_by(account: current_account, key: 'saml_configs')

    @encrypted_config.value ||= {}
  end
end
