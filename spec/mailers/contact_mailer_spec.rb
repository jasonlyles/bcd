require "spec_helper"

describe ContactMailer do
  describe "sending email from the contact form" do
    it "should send me an email and look like it came from the user" do
      @mail = ContactMailer.new_contact_email('Jim Bob','jimbob@legolover.org',"Hey y'all. I like the Legos")
      @mail.subject.should == "New Contact Form"
      @mail.to.should == ["lylesjt@yahoo.com"]
      @mail.from.should == ["sales@brickcitydepot.com"]
      @mail.reply_to.should == ["jimbob@legolover.org"]
      @mail.body.parts.each do |part|
        part.body.should match("Name: Jim Bob")
        part.body.should match("Hey y'all. I like the Legos")
      end
    end
  end
end