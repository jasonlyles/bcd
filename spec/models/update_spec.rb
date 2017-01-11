require 'spec_helper'

describe Update do
  it "should be valid with valid attributes" do
    update = FactoryGirl.create(:update)
    expect(update).to be_valid
  end

  it "should not be valid without a title" do
    update = Update.create(:description => "It's an update!")

    expect(update.errors[:title]).to eq(["can't be blank"])
  end

  it "should not be valid with a body with an incorrect length" do
    skip("Will have to put this test back in when I move from just using images to using images and text.")
    #update = Update.new(:body => "This update is too short.")
    #update.errors_on(:body).should == ["is too short (minimum is 100 characters)"]
  end
end
