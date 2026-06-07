# frozen_string_literal: true

class DepartmentsController < ApplicationController
  load_and_authorize_resource :department, only: %i[index edit update destroy]

  before_action :build_department, only: %i[new create]
  authorize_resource :department, only: %i[new create]

  def index
    @pagy, @departments =
      pagy(@departments.where(account: current_account).preload(:users).order(name: :asc))
  end

  def new; end

  def edit; end

  def create
    if @department.save
      redirect_to settings_departments_path, notice: I18n.t('department_has_been_added')
    else
      render turbo_stream: turbo_stream.replace(:modal, template: 'departments/new'), status: :unprocessable_content
    end
  end

  def update
    if @department.update(department_params)
      redirect_to settings_departments_path, notice: I18n.t('department_has_been_updated')
    else
      render turbo_stream: turbo_stream.replace(:modal, template: 'departments/edit'), status: :unprocessable_content
    end
  end

  def destroy
    @department.destroy!

    redirect_to settings_departments_path, notice: I18n.t('department_has_been_removed')
  end

  private

  def build_department
    @department = current_account.departments.new(department_params)
  end

  def department_params
    if params.key?(:department)
      params.require(:department).permit(:name)
    else
      {}
    end
  end
end
