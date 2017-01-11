require "spec_helper"

describe ProductTypesController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/product_types")).to route_to("product_types#index")
    end

    it "routes to #new" do
      expect(get("/product_types/new")).to route_to("product_types#new")
    end

    it "routes to #show" do
      expect(get("/product_types/1")).to route_to("product_types#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/product_types/1/edit")).to route_to("product_types#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/product_types")).to route_to("product_types#create")
    end

    it "routes to #update" do
      expect(put("/product_types/1")).to route_to("product_types#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/product_types/1")).to route_to("product_types#destroy", :id => "1")
    end

  end
end
