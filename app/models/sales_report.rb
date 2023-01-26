# frozen_string_literal: true

class SalesReport
  attr_accessor :report_date

  def initialize(report_month, report_year)
    @report_date = Date.parse("#{report_month}/#{report_year}")
  end

  def single_month_display
    Date.parse(@report_date.to_s).strftime('%B %Y')
  end

  def generate_sales_report
    orders = orders_for_report_month
    return nil if orders.blank?

    arrange_sales_summaries(orders)
  end

  private

  def orders_for_report_month
    Order.where("upper(status) = 'COMPLETED' and created_at >= ? AND created_at < ?", @report_date.to_s, Date.parse(@report_date.to_s).next_month.strftime('%Y-%m-01').to_s)
  end

  def arrange_sales_summaries(orders)
    blk = ->(hash, key) { hash[key] = Hash.new(&blk) }
    models = Hash.new(&blk)

    orders.includes(:line_items).find_each do |order|
      order.line_items.each do |li|
        # Get product_id for a key, quantity and price
        product_id = li.product_id.to_s
        if models.key?(product_id)
          models[product_id]['qty'] += li.quantity
          models[product_id]['revenue'] += li.total_price
        else
          models[product_id]['qty'] = li.quantity
          models[product_id]['revenue'] = li.total_price
        end
      end
    end
    models
  end
end
