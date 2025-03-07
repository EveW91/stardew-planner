class InventoryItem < ApplicationRecord
  belongs_to :player
  belongs_to :ingredient
end
