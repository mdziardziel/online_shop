class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.string :picture
      t.integer :quantity
      t.datetime :discarded_at
      t.decimal :price

      t.timestamps
    end
  end
end
