class ProductOrder < ActiveRecord::Migration[5.2]
  def change
    create_table :products_orders do |t|
      t.belongs_to :product
      t.belongs_to :order
      t.integer :quantity
      t.decimal :amount

      t.timestamps
    end
  end
end
