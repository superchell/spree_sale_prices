class ChangeDataTypeForValue < ActiveRecord::Migration[4.2]
  def up
    change_column :spree_sale_prices, :value, :decimal, precision: 10, scale: 2, null: false
  end

  def down; end
end
