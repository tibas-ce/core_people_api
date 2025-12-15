class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :name, null: false

      t.timestamps
    end

    add_index :roles, :name
  end
end
