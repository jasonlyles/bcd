require "spec_helper"

describe StaticController do
  describe "routing" do
    it "recognizes and generates train-instructions.html" do
      expect({:get => "train-instructions.html"}).to route_to(:controller => "static", :action => "legacy_train_category", :format => 'html')
    end

    it "recognizes and generates wwii-instructions.html" do
      expect({:get => "wwii-instructions.html"}).to route_to(:controller => "static", :action => "legacy_military_category", :format => 'html')
    end

    it "recognizes and generates wwii-models.html" do
      expect({:get => "wwii-models.html"}).to route_to(:controller => "static", :action => "legacy_military_category", :format => 'html')
    end

    it "recognizes and generates castle-instructions.html" do
      expect({:get => "castle-instructions.html"}).to route_to(:controller => "static", :action => "legacy_castle_category", :format => 'html')
    end

    it "recognizes and generates for-sale.html" do
      expect({:get => "for-sale.html"}).to route_to(:controller => "static", :action => "legacy_instructions", :format => 'html')
    end

    it "recognizes and generates instructions.html" do
      expect({:get => "instructions.html"}).to route_to(:controller => "static", :action => "legacy_instructions", :format => 'html')
    end

    it "recognizes and generates gallery.html" do
      expect({:get => "gallery.html"}).to route_to(:controller => "static", :action => "legacy_gallery", :format => 'html')
    end

    it "recognizes and generates contact-us.html" do
      expect({:get => "contact-us.html"}).to route_to(:controller => "static", :action => "legacy_contact", :format => 'html')
    end

    it "recognizes and generates city-building-instructions.html" do
      expect({:get => "city-building-instructions.html"}).to route_to(:controller => "static", :action => "legacy_city_category", :format => 'html')
    end

    it "recognizes and generates city-vehicles-instructions.html" do
      expect({:get => "city-vehicles-instructions.html"}).to route_to(:controller => "static", :action => "legacy_city_category", :format => 'html')
    end

    it "recognizes and generates city-vehicles.html" do
      expect({:get => "city-vehicles.html"}).to route_to(:controller => "static", :action => "legacy_city_category", :format => 'html')
    end

    it "recognizes and generates modular-buildings.html" do
      expect({:get => "modular-buildings.html"}).to route_to(:controller => "static", :action => "legacy_city_category", :format => 'html')
    end

    it "recognizes and generates winter-village-instructions.html" do
      expect({:get => "winter-village-instructions.html"}).to route_to(:controller => "static", :action => "legacy_winter_village_category", :format => 'html')
    end

    it "recognizes and generates commissions.html" do
      expect({:get => "commissions.html"}).to route_to(:controller => "static", :action => "legacy_commissions", :format => 'html')
    end

    it "recognizes and generates googlehostedservice.html" do
      expect({:get => "googlehostedservice.html"}).to route_to(:controller => "static", :action => "legacy_google_hosted_service", :format => 'html')
    end

    it "recognizes and generates lego_neighborhood_extras.html" do
      expect({:get => "lego_neighborhood_extras.html"}).to route_to(:controller => "static", :action => "legacy_lego_neighborhood_extras", :format => 'html')
    end

    it "recognizes and generates sales-deals.html" do
      expect({:get => "sales-deals.html"}).to route_to(:controller => "static", :action => "legacy_sales_deals", :format => 'html')
    end

    it "recognizes and generates store/p97/Star_Wars_Theme_Sign.html" do
      expect({:get => "store/p97/Star_Wars_Theme_Sign.html"}).to route_to(:controller => "static", :action => "legacy_star_wars_theme_sign", :format => 'html')
    end

    it "recognizes and generates store/p96/Friends_Theme_Sign.html" do
      expect({:get => "store/p96/Friends_Theme_Sign.html"}).to route_to(:controller => "static", :action => "legacy_friends_theme_sign", :format => 'html')
    end

    it "recognizes and generates store/p95/City_Theme_Sign.html" do
      expect({:get => "store/p95/City_Theme_Sign.html"}).to route_to(:controller => "static", :action => "legacy_city_theme_sign", :format => 'html')
    end

    it "recognizes and generates store/p94/Logo_Theme_Sign.html" do
      expect({:get => "store/p94/Logo_Theme_Sign.html"}).to route_to(:controller => "static", :action => "legacy_logo_theme_sign", :format => 'html')
    end

    it "recognizes and generates store/p98/Club_23_Speakeasy_-_Instructions.html" do
      expect({:get => "store/p98/Club_23_Speakeasy_-_Instructions.html"}).to route_to(:controller => "static", :action => "legacy_speakeasy_instructions", :format => 'html')
    end

    it "recognizes and generates store/p93/Architecture_Firm__-_Instructions.html" do
      expect({:get => "store/p93/Architecture_Firm__-_Instructions.html"}).to route_to(:controller => "static", :action => "legacy_archfirm_instructions", :format => 'html')
    end

    it "recognizes and generates store/p79/Menswear_Shop_Instructions.html" do
      expect({:get => "store/p79/Menswear_Shop_Instructions.html"}).to route_to(:controller => "static", :action => "legacy_menswear_instructions", :format => 'html')
    end

    it "recognizes and generates books.html" do
      expect({:get => "books.html"}).to route_to(:controller => "static", :action => "legacy_books", :format => 'html')
    end

    it "recognizes and generates lego_prints.html" do
      expect({:get => "lego_prints.html"}).to route_to(:controller => "static", :action => "legacy_lego_prints", :format => 'html')
    end

    it "recognizes and generates custom-letters.html" do
      expect({:get => "custom-letters.html"}).to route_to(:controller => "static", :action => "legacy_custom_letters", :format => 'html')
    end

    it "recognizes and generates name-signs.html" do
      expect({:get => "name-signs.html"}).to route_to(:controller => "static", :action => "legacy_name_signs", :format => 'html')
    end

    it "recognizes and generates #index" do
      expect({:get => "/"}).to route_to(:controller => "static", :action => "index")
    end

    it "recognizes and generates #contact" do
      expect({:get => "/contact"}).to route_to(:controller => "static", :action => "contact")
    end

    it "recognizes and generates #faq" do
      expect({:get => "/faq"}).to route_to(:controller => "static", :action => "faq")
    end

    it "recognizes and generates #privacy_policy" do
      expect({:get => "/privacy_policy"}).to route_to(:controller => "static", :action => "privacy_policy")
    end

    it "recognizes and generates #terms_of_service" do
      expect({:get => "/terms_of_service"}).to route_to(:controller => "static", :action => "terms_of_service")
    end
  end
end