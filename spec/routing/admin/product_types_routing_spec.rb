require "spec_helper"

describe Admin::ProductTypesController do
  describe "routing" do

    it "routes to #index" do
      expect(get("admin/product_types")).to route_to("admin/product_types#index")
    end

    it "routes to #new" do
      expect(get("admin/product_types/new")).to route_to("admin/product_types#new")
    end

    it "routes to #show" do
      expect(get("admin/product_types/1")).to route_to("admin/product_types#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("admin/product_types/1/edit")).to route_to("admin/product_types#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("admin/product_types")).to route_to("admin/product_types#create")
    end

    it "routes to #update" do
      expect(put("admin/product_types/1")).to route_to("admin/product_types#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("admin/product_types/1")).to route_to("admin/product_types#destroy", :id => "1")
    end

  end
end
