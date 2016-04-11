require 'faker'

# This file contains code that populates the database with
# fake data for testing purposes

def db_seed
    5.times do
        Product.create(brand: "WalterToys", name: "Sticky Notes", price: 34.00)
    end
end
