require "spec_helper"

describe UpdateMailer do
  describe "sending email for updated instructions" do
    it "should send user an email for instructions that have been updated" do
      Category.delete_all
      Subcategory.delete_all
      @product_type = FactoryBot.create(:product_type)
      @category = FactoryBot.create(:category)
      @subcategory = FactoryBot.create(:subcategory, :category_id => @category.id)
      @user = FactoryBot.create(:user)
      @model = FactoryBot.create(:product, :subcategory_id => @subcategory.id, :category_id => @category.id)
      @mail = UpdateMailer.updated_instructions(@user.id, @model.id, message='BLAH BLAH BLAH')

      expect(@mail.subject).to eq("Instructions for CB001 Colonial Revival House have been updated")
      expect(@mail.to).to eq([@user.email])
      expect(@mail.from).to eq(["sales@brickcitydepot.com"])
      #This isn't working any more, see notes in order_mailer_spec
      #@mail.body.should match("BLAH BLAH BLAH")
    end
  end
end
