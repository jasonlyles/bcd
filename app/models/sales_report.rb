# frozen_string_literal: true

class SalesReport < ApplicationRecord
  has_many :sales_summaries, :dependent => :destroy
  attr_accessor :start_date, :end_date, :single_month
  # attr_accessible :start_date, :end_date, :report_date

  def multiple_months?
    start_date = Date.parse("#{report_date}")
    e_date = if end_date.blank? || end_date['month'].blank? || end_date['year'].blank?
               nil
             else
               Date.parse("#{end_date['month']}/#{end_date['year']}")
             end
    e_date.blank? ? false : start_date < e_date
  end

  def single_month_display
    Date.parse("#{report_date}").strftime("%B %Y")
  end

  def multiple_months_display
    "#{Date.parse("#{report_date}").strftime("%b %Y")} - #{Date.parse("#{end_date['month']}/#{end_date['year']}").strftime("%b %Y")}"
  end

  def self.get_sweet_stats(start_month, start_year, end_month, end_year)
    # Dress up the month nums a bit for querying
    start_month = "0#{start_month}" if start_month.to_s.length == 1
    unless end_month.blank?
      end_month = "0#{end_month}" if end_month.to_s.length == 1
    end

    sales_reports = if end_month.blank? || end_year.blank?
                      SalesReport.where('report_date = ?', "#{start_year}-#{start_month}-01")
                    else
                      SalesReport.where('report_date >= ? AND report_date < ?', "#{start_year}-#{start_month}-01", "#{Date.parse("#{end_month}/#{end_year}").next_month.strftime("%Y-%m-01")}")
                    end

    blk = lambda { |hash, key| hash[key] = Hash.new(&blk) }
    models = Hash.new(&blk)

    sales_reports.each do |report|
      report.sales_summaries.each do |ss|
        if models.key?("#{ss.product_id}")
          models["#{ss.product_id}"]['qty'] += ss.quantity
          models["#{ss.product_id}"]['revenue'] += ss.total_revenue
        else
          models["#{ss.product_id}"]['qty'] = ss.quantity
          models["#{ss.product_id}"]['revenue'] = ss.total_revenue
        end
      end
    end
    models
  end

  def generate_sales_report
    orders = orders_for_report_month
    unless orders.blank?
      models = arrange_sales_summaries(orders)
      models.each do |model|
        ss = SalesSummary.new(sales_report_id: id, product_id: model[0].to_i, quantity: model[1]['qty'].to_i, total_revenue: model[1]['revenue'])
        ss.save
      end
      models
    else
      nil
    end
  end

  private

  def orders_for_report_month
    Order.where("upper(status) = 'COMPLETED' and created_at >= ? AND created_at < ?", "#{report_date}", "#{Date.parse("#{report_date}").next_month.strftime("%Y-%m-01")}")
  end

  def arrange_sales_summaries(orders)
    blk = lambda { |hash, key| hash[key] = Hash.new(&blk) }
    models = Hash.new(&blk)

    orders.find_each do |order|
      order.line_items.each do |li|
        # Get product_id for a key, quantity and price
        if models.key?("#{li.product_id}")
          models["#{li.product_id}"]['qty'] += li.quantity
          models["#{li.product_id}"]['revenue'] += li.total_price
        else
          models["#{li.product_id}"]['qty'] = li.quantity
          models["#{li.product_id}"]['revenue'] = li.total_price
        end
      end
    end
    models
  end
end
