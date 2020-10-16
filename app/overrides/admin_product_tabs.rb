code = <<-CODE
  <%= content_tag(:li) do %>
    <% item_active = current == :product_sale_price_tab ? ' active ' : '' %>
    <%= link_to_with_icon 'money', Spree.t(:product_sale_prices), admin_product_sale_prices_path(@product), 
                      class: 'nav-link' + item_active %>
  <% end %>
CODE

Deface::Override.new(
  virtual_path: "spree/admin/shared/_product_tabs",
  name: "add_sale_prices_tab",
  insert_bottom: "[data-hook='admin_product_tabs']",
  text: code,
  disabled: false)