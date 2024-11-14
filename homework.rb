require 'date'

class Stock
  attr_reader :name

  def initialize(name, prices = {})
    @name = name
    @prices = prices.transform_keys { |date| Date.parse(date.to_s) }
                    .transform_values(&:to_f)
  end

  def price(date)
    date = Date.parse(date.to_s) unless date.is_a?(Date)
    @prices[date] || 0.0
  end
end

class Portfolio
  def initialize
    @stocks = []
  end

  def add_stock(stock)
    raise ArgumentError, "Invalid stock object" unless stock.is_a?(Stock)
    @stocks << stock
  end

  def profit(start_date, end_date)
    start_date, end_date = validate_dates(start_date, end_date)
    calculate_value_change(start_date, end_date)
  end

  def annualized_return(start_date, end_date)
    start_date, end_date = validate_dates(start_date, end_date)
    days = (end_date - start_date).to_i

    initial_value = portfolio_value(start_date).to_f
    final_value = portfolio_value(end_date).to_f
    return 0.0 if initial_value.zero?

    total_return = (final_value - initial_value) / initial_value
    annualized_return = (1 + total_return) ** (365.0 / days) - 1
    (annualized_return * 100).round(2)
  end

  private

  def validate_dates(start_date, end_date)
    start_date = Date.parse(start_date.to_s)
    end_date = Date.parse(end_date.to_s)
    raise ArgumentError, "End date must be after start date" if end_date <= start_date

    [start_date, end_date]
  end

  def portfolio_value(date)
    @stocks.sum { |stock| stock.price(date) }
  end

  def calculate_value_change(start_date, end_date)
    initial_value = portfolio_value(start_date)
    final_value = portfolio_value(end_date)
    final_value - initial_value
  end
end

fintual = Stock.new("fintual", { "2024-01-01" => 100, "2024-12-31" => 180 })
platanus = Stock.new("platanus", { "2024-01-01" => 1200, "2024-12-31" => 1350 })

portfolio = Portfolio.new
portfolio.add_stock(fintual)
portfolio.add_stock(platanus)

puts "Profit: #{portfolio.profit("2024-01-01", "2024-12-31")}"
puts "Annualized Return: #{portfolio.annualized_return("2024-01-01", "2024-12-31")} %"
