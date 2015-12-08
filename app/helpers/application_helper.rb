module ApplicationHelper
  def format_price(price, precision: 2)
    number_to_currency(price, precision: precision)
  end
end
