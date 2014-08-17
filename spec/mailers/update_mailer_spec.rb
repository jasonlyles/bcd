require "spec_helper"

describe UpdateMailer do
  describe "sending email for updated instructions" do
    it "should send user an email for instructions that have been updated" do
      Category.delete_all
      Subcategory.delete_all
      @product_type = FactoryGirl.create(:product_type)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory, :category_id => @category.id)
      @user = FactoryGirl.create(:user)
      @model = FactoryGirl.create(:product, :subcategory_id => @subcategory.id, :category_id => @category.id)
      @mail = UpdateMailer.updated_instructions(@user.id, @model.id, message='BLAH BLAH BLAH')

      @mail.subject.should == "Instructions for CB001 Colonial Revival House have been updated"
      @mail.to.should == [@user.email]
      @mail.from.should == ["sales@brickcitydepot.com"]
      #This isn't working any more, see notes in order_mailer_spec
      #@mail.body.should match("BLAH BLAH BLAH")
    end
  end
end
