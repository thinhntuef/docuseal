# frozen_string_literal: true

class CreateDepartments < ActiveRecord::Migration[8.0]
  def change
    create_table :departments do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :uuid, null: false

      t.timestamps
    end

    add_index :departments, :uuid, unique: true
    add_index :departments, %i[account_id name], unique: true

    add_reference :users, :department, null: true, foreign_key: true
    add_reference :templates, :department, null: true, foreign_key: true
    add_reference :template_folders, :department, null: true, foreign_key: true
  end
end
