class Order < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :status
      t.decimal :amount
      t.string :token, unique: true

      t.timestamps
    end
  end
end
