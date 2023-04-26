# Pinterest

## App

My apps: https://developers.pinterest.com/apps/

Dev is trial access for the API. Staging and prod will be full access.

## Dev

### Info

API reference: https://developers.pinterest.com/docs/api/v5/

Getting Started: https://developers.pinterest.com/docs/getting-started/set-up-app/

Edit profile: https://www.pinterest.com/settings/edit-profile/

Business Hub: https://www.pinterest.com/business/hub/

### Notes

## Misc

## Background Jobs

1. RefreshPinterestAccessTokenJob is scheduled to run every 29 days to refresh our Pinterest OAuth access token.

## Notes

Refresh tokens have a lifespan of 365 days.

Basic API workflow:
 1. Go to the oauth pinterest url, passing in state. We generate a state that we store in session.
 2. We authorize the app and are redirected to the callback url, where we retrieve the code that Pinterest sends back to us, and the state from session. We confirm that the state in session matches what we got back from Pinterest, and then send the code back to Pinterest to verify and get our access tokens.
 3. We store the access and refresh tokens we got back from Pinterest in the database so they can be used for API calls originating in a Sidekiq job.
