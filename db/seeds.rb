# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

FactoryBot.create_list(:product, 15) if Product.count <= 10

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if AdminUser.count == 0

