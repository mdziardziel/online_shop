json.extract! product, :id, :name, :description, :picture, :quantity, :discarded_at, :price, :created_at, :updated_at
json.url product_url(product, format: :json)
