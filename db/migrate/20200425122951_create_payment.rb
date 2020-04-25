class CreatePayment < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.belongs_to :order
      t.jsonb :buyer, default: {}
      t.jsonb :provider_data, default: {}
      t.string :status
      t.decimal :amount

      t.timestamps
    end
  end
end
