require "spec_helper"

describe StaticController do
  describe "routing" do
    it "recognizes and generates train-instructions.html" do
      {:get => "train-instructions.html"}.should route_to(:controller => "static", :action => "legacy_train_category", :format => 'html')
    end

    it "recognizes and generates wwii-instructions.html" do
      {:get => "wwii-instructions.html"}.should route_to(:controller => "static", :action => "legacy_military_category", :format => 'html')
    end

    it "recognizes and generates wwii-models.html" do
      {:get => "wwii-models.html"}.should route_to(:controller => "static", :action => "legacy_military_category", :format => 'html')
    end

    it "recognizes and generates castle-instructions.html" do
      {:get => "castle-instructions.html"}.should route_to(:controller => "static", :action => "legacy_castle_category", :format => 'html')
    end

    it "recognizes and generates for-sale.html" do
      {:get => "for-sale.html"}.should route_to(:controller => "static", :action => "legacy_instructions", :format => 'html')
    end

    it "recognizes and generates instructions.html" do
      {:get => "instructions.html"}.should route_to(:controller => "static", :action => "legacy_instructions", :format => 'html')
    end

    it "recognizes and generates gallery.html" do
      {:get => "gallery.html"}.should route_to(:controller => "static", :action => "legacy_gallery", :format => 'html')
    end

    it "recognizes and generates contact-us.html" do
      {:get => "contact-us.html"}.should route_to(:controller => "static", :action => "legacy_contact", :format => 'html')
    end

    it "recognizes and generates city-building-instructions.html" do
      {:get => "city-building-instructions.html"}.should route_to(:controller => "static", :action => "legacy_city_category", :format => 'html')
    end

    it "recognizes and generates city-vehicles-instructions.html" do
      {:get => "city-vehicles-instructions.html"}.should route_to(:controller => "static", :action => "legacy_city_category", :format => 'html')
    end

    it "recognizes and generates city-vehicles.html" do
      {:get => "city-vehicles.html"}.should route_to(:controller => "static", :action => "legacy_city_category", :format => 'html')
    end

    it "recognizes and generates modular-buildings.html" do
      {:get => "modular-buildings.html"}.should route_to(:controller => "static", :action => "legacy_city_category", :format => 'html')
    end

    it "recognizes and generates winter-village-instructions.html" do
      {:get => "winter-village-instructions.html"}.should route_to(:controller => "static", :action => "legacy_winter_village_category", :format => 'html')
    end

    it "recognizes and generates commissions.html" do
      {:get => "commissions.html"}.should route_to(:controller => "static", :action => "legacy_commissions", :format => 'html')
    end

    it "recognizes and generates googlehostedservice.html" do
      {:get => "googlehostedservice.html"}.should route_to(:controller => "static", :action => "legacy_google_hosted_service", :format => 'html')
    end

    it "recognizes and generates lego_neighborhood_extras.html" do
      {:get => "lego_neighborhood_extras.html"}.should route_to(:controller => "static", :action => "legacy_lego_neighborhood_extras", :format => 'html')
    end

    it "recognizes and generates sales-deals.html" do
      {:get => "sales-deals.html"}.should route_to(:controller => "static", :action => "legacy_sales_deals", :format => 'html')
    end

    it "recognizes and generates store/p97/Star_Wars_Theme_Sign.html" do
      {:get => "store/p97/Star_Wars_Theme_Sign.html"}.should route_to(:controller => "static", :action => "legacy_star_wars_theme_sign", :format => 'html')
    end

    it "recognizes and generates store/p96/Friends_Theme_Sign.html" do
      {:get => "store/p96/Friends_Theme_Sign.html"}.should route_to(:controller => "static", :action => "legacy_friends_theme_sign", :format => 'html')
    end

    it "recognizes and generates store/p95/City_Theme_Sign.html" do
      {:get => "store/p95/City_Theme_Sign.html"}.should route_to(:controller => "static", :action => "legacy_city_theme_sign", :format => 'html')
    end

    it "recognizes and generates store/p94/Logo_Theme_Sign.html" do
      {:get => "store/p94/Logo_Theme_Sign.html"}.should route_to(:controller => "static", :action => "legacy_logo_theme_sign", :format => 'html')
    end

    it "recognizes and generates store/p98/Club_23_Speakeasy_-_Instructions.html" do
      {:get => "store/p98/Club_23_Speakeasy_-_Instructions.html"}.should route_to(:controller => "static", :action => "legacy_speakeasy_instructions", :format => 'html')
    end

    it "recognizes and generates store/p93/Architecture_Firm__-_Instructions.html" do
      {:get => "store/p93/Architecture_Firm__-_Instructions.html"}.should route_to(:controller => "static", :action => "legacy_archfirm_instructions", :format => 'html')
    end

    it "recognizes and generates store/p79/Menswear_Shop_Instructions.html" do
      {:get => "store/p79/Menswear_Shop_Instructions.html"}.should route_to(:controller => "static", :action => "legacy_menswear_instructions", :format => 'html')
    end

    it "recognizes and generates books.html" do
      {:get => "books.html"}.should route_to(:controller => "static", :action => "legacy_books", :format => 'html')
    end

    it "recognizes and generates lego_prints.html" do
      {:get => "lego_prints.html"}.should route_to(:controller => "static", :action => "legacy_lego_prints", :format => 'html')
    end

    it "recognizes and generates custom-letters.html" do
      {:get => "custom-letters.html"}.should route_to(:controller => "static", :action => "legacy_custom_letters", :format => 'html')
    end

    it "recognizes and generates name-signs.html" do
      {:get => "name-signs.html"}.should route_to(:controller => "static", :action => "legacy_name_signs", :format => 'html')
    end

    it "recognizes and generates #index" do
      {:get => "/"}.should route_to(:controller => "static", :action => "index")
    end

    it "recognizes and generates #contact" do
      {:get => "/contact"}.should route_to(:controller => "static", :action => "contact")
    end

    it "recognizes and generates #faq" do
      {:get => "/faq"}.should route_to(:controller => "static", :action => "faq")
    end

    it "recognizes and generates #privacy_policy" do
      {:get => "/privacy_policy"}.should route_to(:controller => "static", :action => "privacy_policy")
    end

    it "recognizes and generates #terms_of_service" do
      {:get => "/terms_of_service"}.should route_to(:controller => "static", :action => "terms_of_service")
    end
  end
end