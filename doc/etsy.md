# Etsy

## App

name: Brick City Depot

url: https://www.etsy.com/shop/BCDTest

My listings: https://www.etsy.com/your/shops/BCDTest/tools/listings

My apps: https://www.etsy.com/developers/your-apps

Shop manager: https://www.etsy.com/your/shops/me/dashboard?ref=seller-platform-mcnav

## Dev

### Info

When testing, you have to test in prod. As such, there is a testing policy that involves setting up a test store for the testing and other recommended practices: https://www.etsy.com/legal/policy/api-testing-policy/169130941112

API reference: https://developers.etsy.com/documentation/reference/

Turn off developer mode in the store: https://www.etsy.com/developers/shop

Github discussions: https://github.com/etsy/open-api/discussions

### Notes

To test handling receipts locally:
In Etsy::Api::Receipt#shop_receipts, comment out the call to api_get, and uncomment the call to stub_shop_receipts
sr = Etsy::Api::Receipt.new.shop_receipts((Time.now - 2.weeks).to_i); ehr = Etsy::Handler::Receipts.new(sr); ehr.handle

To test adding listings locally:
In Etsy::Client#create_listing, comment out "response = listing.activate" so we're not actually publishing the listing and incurring costs.

## Misc

Sample competitor listing: https://www.etsy.com/listing/621551224/stickers-and-instructions-to-build-a

## Background Jobs

1. RefreshEtsyAccessTokenJob is scheduled to run every 55 minutes to refresh our Etsy OAuth access token.
2. FindNewEtsyOrdersJob is scheduled to run every 5 minutes looking for new orders from Etsy.
3. UpdateAllEtsyPdfsJob is triggered ad hoc when we need to update all Etsy PDFs.

## Notes

Refresh tokens have a lifespan of 90 days.

Basic API workflow:
 1. Go to the oauth etsy url, passing in state and code_challenge params. We generate a code_verifier string at the same time as the code_challenge that we store in session.
 2. We authorize the app and are redirected to the callback url, where we retrieve the code that Etsy sends back to us, and the code_verifier from session. We then send those back to Etsy to verify and get our access tokens.
 3. We store the access and refresh tokens we got back from Etsy in the database so they can be used for API calls originating in a Sidekiq job.

"Building & Construction" taxonomy_id is 1583. This is the closest to what I want, I think.
