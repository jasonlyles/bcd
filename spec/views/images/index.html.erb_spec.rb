require 'spec_helper'

describe 'images/index.html.erb' do
  #=begin
  before(:each) do
    image1 = FactoryGirl.create(:image)
    image2 = FactoryGirl.create(:image)
    #     assign(:images, [
    #         stub_model(Image,
    #                    :url => fixture_file_upload("files/example.png", "image/png"),
    #                    :product_id => 1
    #         ),
    #         stub_model(Image,
    #                    :url => fixture_file_upload("files/example.png", "image/png"),
    #                    :product_id => 1
    #         )
    #      ])
    #     assign(:images, [
    #       stub_model(FactoryGirl.create(:image)),
    #       stub_model(FactoryGirl.create(:image))
    #     ])
    #     #@images = []
    #     #image1 = stub_model(FactoryGirl.create(:image))
    #     #image1.save!
    #     #@images << image1
    #     @image = assign(:image, stub_model(Image,
    #                                        :url => fixture_file_upload("files/example.png", "image/png")
    #     ))
  end
  #=end

  it 'renders a list of images' do
    skip("Images aren't getting created, figure out why")
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'tr>td', text: 'Filename'.to_s, count: 2
  end
end
