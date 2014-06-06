require "spec_helper"

describe ContactMailer do
  let(:email) { FactoryGirl.build(:email) }
  let(:mail) { ContactMailer.new_contact_email(email) }

  describe "sending email from the contact form" do
    it "should send me an email and look like it came from the user" do
      mail.subject.should == "Brick City Depot contact form"
      mail.to.should == ["lylesjt@yahoo.com"]
      mail.from.should == ["jimbob@legolover.org"]
      mail.body.parts.each do |part|
        part.body.should match("Name: Jim Bob")
        part.body.should match("Hey ya'll. I like the Legos")
      end
    end
  end
end