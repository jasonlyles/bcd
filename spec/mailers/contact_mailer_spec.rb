require 'spec_helper'

describe ContactMailer do
  describe 'sending email from the contact form' do
    it 'should send me an email and look like it came from the user' do
      @mail = ContactMailer.new_contact_email('Jim Bob', 'jimbob@legolover.org', "Hey y'all. I like the Legos")
      expect(@mail.subject).to eq('New Contact Form')
      expect(@mail.to).to eq(['lylesjt@yahoo.com'])
      expect(@mail.from).to eq(['sales@brickcitydepot.com'])
      expect(@mail.reply_to).to eq(['jimbob@legolover.org'])
      @mail.body.parts.each do |part|
        expect(part.body.to_s).to match('Jim Bob')
        expect(part.body.to_s).to match('I like the Legos')
      end
    end
  end
end
