require 'spec_helper'

describe PasswordsController do
  #Testing any more than this for the create method gets into Devise behavior that I haven't overridden, and is redundant,
  #since there are tests for it in Devise.
  describe "create" do
    it "should render the form again if the email is not in the database" do
      request.env['devise.mapping'] = Devise.mappings[:user]
      get :create, params: { user: { email: 'blar' } }

      expect(flash[:alert]).to eq("Was not able to find that email. Please make sure you entered the correct email address.")
      expect(response).to redirect_to('/users/password/new')
    end
  end

end
