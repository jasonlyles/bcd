# frozen_string_literal: true

class SalesReport < ApplicationRecord
  has_many :sales_summaries, dependent: :destroy
  attr_accessor :start_date, :end_date, :single_month

  # attr_accessible :start_date, :end_date, :report_date

  def multiple_months?
    start_date = Date.parse(report_date.to_s)
    e_date = if end_date.blank? || end_date['month'].blank? || end_date['year'].blank?
               nil
             else
               Date.parse("#{end_date['month']}/#{end_date['year']}")
             end
    e_date.blank? ? false : start_date < e_date
  end

  def single_month_display
    Date.parse(report_date.to_s).strftime('%B %Y')
  end

  def multiple_months_display
    "#{Date.parse(report_date.to_s).strftime('%b %Y')} - #{Date.parse("#{end_date['month']}/#{end_date['year']}").strftime('%b %Y')}"
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def self.get_sweet_stats(start_month, start_year, end_month, end_year)
    # Dress up the month nums a bit for querying
    start_month = "0#{start_month}" if start_month.to_s.length == 1
    end_month = "0#{end_month}" if end_month&.to_s&.length == 1

    sales_reports = if end_month.blank? || end_year.blank?
                      SalesReport.where('report_date = ?', "#{start_year}-#{start_month}-01")
                    else
                      SalesReport.where('report_date >= ? AND report_date < ?', "#{start_year}-#{start_month}-01", Date.parse("#{end_month}/#{end_year}").next_month.strftime('%Y-%m-01').to_s)
                    end

    blk = ->(hash, key) { hash[key] = Hash.new(&blk) }
    models = Hash.new(&blk)

    sales_reports.each do |report|
      report.sales_summaries.each do |ss|
        product_id = ss.product_id.to_s
        if models.key?(product_id)
          models[product_id]['qty'] += ss.quantity
          models[product_id]['revenue'] += ss.total_revenue
        else
          models[product_id]['qty'] = ss.quantity
          models[product_id]['revenue'] = ss.total_revenue
        end
      end
    end
    models
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def generate_sales_report
    orders = orders_for_report_month
    return nil if orders.blank?

    models = arrange_sales_summaries(orders)
    models.each do |model|
      ss = SalesSummary.new(sales_report_id: id, product_id: model[0].to_i, quantity: model[1]['qty'].to_i, total_revenue: model[1]['revenue'])
      ss.save
    end
    models
  end

  private

  def orders_for_report_month
    Order.where("upper(status) = 'COMPLETED' and created_at >= ? AND created_at < ?", report_date.to_s, Date.parse(report_date.to_s).next_month.strftime('%Y-%m-01').to_s)
  end

  def arrange_sales_summaries(orders)
    blk = ->(hash, key) { hash[key] = Hash.new(&blk) }
    models = Hash.new(&blk)

    orders.find_each do |order|
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
