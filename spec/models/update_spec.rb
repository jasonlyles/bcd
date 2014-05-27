require 'spec_helper'

describe Update do
  it "should be valid with valid attributes" do
    update = FactoryGirl.create(:update)
    update.should be_valid
  end

  it "should not be valid without a title" do
    update = Update.new(:description => "It's an update!")
    update.errors_on(:title).should == ["can't be blank"]
  end

  it "should not be valid with a body with an incorrect length" do
    pending("Will have to put this test back in when I move from just using images to using images and text.")
    #update = Update.new(:body => "This update is too short.")
    #update.errors_on(:body).should == ["is too short (minimum is 100 characters)"]
  end
end
