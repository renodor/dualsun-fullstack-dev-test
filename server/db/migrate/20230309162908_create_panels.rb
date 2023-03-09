class CreatePanels < ActiveRecord::Migration[6.1]
  def change
    create_table :panels do |t|
      t.integer :code, null: false
      t.integer :flavor, null: false

      t.references :installation, foreign_key: true, null: false

      t.timestamps
    end
  end
end
