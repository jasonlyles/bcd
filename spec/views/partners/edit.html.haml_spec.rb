require 'spec_helper'

describe "partners/edit.html.haml" do
  before(:each) do
    @partner = assign(:partner, stub_model(Partner,
      :name => "MyString",
      :url => "MyString",
      :contact => "MyString"
    ))
  end

  it "renders the edit partner form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => partner_path(@partner), :method => "post" do
      assert_select "input#partner_name", :name => "partner[name]"
      assert_select "input#partner_url", :name => "partner[url]"
      assert_select "input#partner_contact", :name => "partner[contact]"
    end
  end
end
