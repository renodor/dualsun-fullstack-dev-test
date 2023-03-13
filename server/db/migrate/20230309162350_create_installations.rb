class CreateInstallations < ActiveRecord::Migration[6.1]
  def change
    create_table :installations do |t|
      t.date :date, null: false
      t.string :address, null: false
      t.string :city, null: false

      t.references :company, foreign_key: true, null: false
      t.references :customer, foreign_key: true, null: false

      t.timestamps
    end
  end
end
