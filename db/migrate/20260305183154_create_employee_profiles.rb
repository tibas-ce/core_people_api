class CreateEmployeeProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :employee_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      # Dados pessoais
      t.string :cpf, null: false, limit: 11
      t.date :birth_date
      t.string :phone, limit: 11
      t.text :address

      # Dados profissionais
      t.string :position, null: false
      t.string :department
      t.decimal :salary, precision: 10, scale: 2
      t.date :hire_date, null: false
      t.date :termination_date

      # Status
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :employee_profiles, :cpf, unique: true
    add_index :employee_profiles, :status
  end
end
