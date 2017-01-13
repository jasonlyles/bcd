FactoryGirl.define do
  factory :instant_payment_notification do
    order_id 1
    payment_status 'Completed'
    notify_version '3.8'
    request_id 'asdfasdf'
    verify_sign '1234qwer'
    payer_email 'bob@bob.mil'
    txn_id '0987qwerty'
    params {
      {'mc_gross' => 12}
    }
    processed true
  end
end