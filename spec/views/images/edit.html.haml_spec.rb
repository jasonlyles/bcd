require 'spec_helper'

describe "images/edit.html.haml" do
  before(:each) do
    @image = assign(:image, stub_model(Image,
      :url => fixture_file_upload("files/example.png", "image/png")
    ))
    @products = []
  end

  it "renders the edit image form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => image_path(@image), :method => "post" do
      assert_select "input#image_url", :name => "image[url]"
    end
  end
end
