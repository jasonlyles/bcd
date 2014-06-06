#This class handles the IPN response from Paypal
class InstantPaymentNotification
  attr_accessor :payment_type, :payment_date, :payment_status, :payer_status, :payer_email, :business, :receiver_email,
              :mc_currency, :mc_fee, :mc_gross, :txn_type, :txn_id, :notify_version, :verify_sign, :params, :order, :custom,
              :address_state, :address_street, :address_country, :address_zip, :address_city, :address_name,
              :first_name, :last_name

  def initialize(params)
    @params = params
    @params.each{|key,v| eval("@#{key}=v")}
    find_order
  end

  def valid_business_value?
    @business == PaypalConfig.config.business_email
  end

  def valid_currency?
    @mc_currency == 'USD'
  end

  def valid_amount?
    @mc_gross.to_f == @order.total_price
  end

  def valid_payment_status?
    @payment_status.upcase == "COMPLETED"
  end

  #Check to see if the transaction ID already exists in the database. If so, don't process this transaction.
  #I don't think I want to use this. I think paypal might call back to me a couple of times for a transaction to update me
  def unique_transaction?
    order = Order.find_by_transaction_id(@txn_id)
    !order
  end

  #@custom is the generated RequestID
  def find_order
    @order = Order.find_by_request_id(@custom)
  end

  #Make sure IPN is valid by making a call to $config['paypal']['url']/cgi-bin/webscr? cmd=_notify_validate plus
  #all the variables that I got from paypal, in the same order I received them.
  def valid_ipn?
    http = Net::HTTP.new(PaypalConfig.config.host, 443)
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.use_ssl=true
    path = "/cgi-bin/webscr"
    query = "cmd=_notify-validate"
    #Might need to URL.encode the query string
    @params.each do |key,value|
      query += "&#{key}=#{value}"
    end
    response = http.post(path,query)

    if response && response.code == '200' && response.body == 'VERIFIED'
      return true
    else
      return false
    end
  end

  def valid?
    valid_ipn? && valid_amount? && valid_currency? && valid_business_value? && valid_payment_status?
  end
end