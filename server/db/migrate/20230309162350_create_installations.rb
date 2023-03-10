class CreateInstallations < ActiveRecord::Migration[6.1]
  def change
    create_table :installations do |t|
      t.date :date, null: false
      t.string :address1, null: false
      t.string :address2
      t.string :zipcode
      t.string :city, null: false
      t.string :country, null: false

      t.references :company, foreign_key: true, null: false
      t.references :customer, foreign_key: true, null: false

      t.timestamps
    end
  end
end