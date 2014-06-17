require 'spec_helper'

describe StoreController do
  before do
    @product_type = FactoryGirl.create(:product_type)
  end

  def mock_order(stubs={})
    (@mock_order ||= mock_model(Order).as_null_object).tap do |order|
      order.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET cart" do
    it "should render the cart page" do
      get :cart

      response.should render_template('cart')
    end

    it "should add errant items to flash notice" do
      @product_type2 = FactoryGirl.create(:product_type, :name => 'Models', :digital_product => false)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @base_product = FactoryGirl.create(:product, :category_id => @category.id, :subcategory_id => @subcategory.id, :product_type_id => @product_type.id, :name => "Winter Village Flak Cannon", :quantity => 1, :product_code => 'WV009')
      @product = FactoryGirl.create(:product, :category_id => @category.id, :subcategory_id => @subcategory.id, :product_type_id => @product_type2.id, :name => "Winter Village Flak Cannon Model", :quantity => 3, :product_code => 'WV009M')
      @cart = FactoryGirl.create(:cart)
      @cart_item = FactoryGirl.create(:cart_item, :product_id => @product.id, :cart_id => @cart.id, :quantity => 5)
      @cart.cart_items << @cart_item
      @cart.save
      session[:cart_id] = @cart.id
      get :cart

      flash[:notice].should match("Please reduce quantities or remove")
      flash[:notice].should match("Winter Village Flak Cannon")
    end
  end

  describe "categories" do
    it 'should redirect to index and flash a message if category cant be found in the database' do
      setup_products
      get :categories, :product_type_name => 'Instructions', :category_name => 'Junk'

      flash[:notice].should eq "Sorry. That product category does not exist."
      response.should redirect_to('/store')
    end

    it "given a category name it should find all products for sale in a category" do
      setup_products
      get :categories, :product_type_name => 'Instructions', :category_name => 'City'

      assigns(:products).length.should eq(2)
    end

    it "should get only alternatives when searching on alternatives" do
      setup_products
      get :categories, :product_type_name => 'Instructions', :category_name => 'Alternatives'

      assigns(:products).length.should eq(1)
    end

    it "should get all products for a given price group when searching for products at that price" do
      setup_products
      get :categories, :product_type_name => 'Instructions', :category_name => 'group_on_price', :price => '5'

      assigns(:products).length.should eq(1)
      assigns(:category).name.should eq('$5 instructions')

      get :categories, :product_type_name => 'Instructions', :category_name => 'group_on_price', :price => '3'

      assigns(:products).length.should eq(2)
      assigns(:category).name.should eq('$3 instructions')

      get :categories, :product_type_name => 'Instructions', :category_name => 'group_on_price', :price => '7.34'

      assigns(:products).length.should eq(0)
      assigns(:category).name.should eq('$7.34 instructions')
    end

    it "should get all free products when searching for freebies" do
      setup_products
      get :categories, :product_type_name => 'Instructions', :category_name => 'group_on_price', :price => 'free'

      assigns(:products).length.should eq(1)
      assigns(:category).name.should eq('Completely FREE Instructions!')
    end
  end

  describe "add_to_cart" do
    it "should not add to cart if the item is a freebie" do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:free_product)
      @cart = Cart.new
      request.env["HTTP_REFERER"] = '/'
      get :add_to_cart, :product_code => @product.product_code

      assigns(:cart).cart_items.length.should == 0
      response.should redirect_to('/')
      flash[:notice].should == "You don't need to add free instructions to your cart. Just go to your account page to download them."
    end

    it "should add an item to the cart" do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @cart = Cart.new
      request.env["HTTP_REFERER"] = '/'
      get :add_to_cart, :product_code => @product.product_code

      assigns(:cart).cart_items.length.should == 1
      response.should redirect_to('/')
      flash[:notice].should == "Item added to cart."
    end

    it "should not add to cart if the item is already in the cart" do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product, :product_type_id => @product_type.id)
      @cart = Cart.new
      request.env["HTTP_REFERER"] = '/'
      get :add_to_cart, :product_code => @product.product_code
      get :add_to_cart, :product_code => @product.product_code

      assigns(:cart).cart_items.length.should == 1
      response.should redirect_to('/')
      flash[:notice].should == "You already have #{@product.name} in your cart. You don't need to purchase more than 1 set of the same instructions."
    end

    it "should redirect back with a nasty notice if an invalid product code is passed in" do
      @cart = Cart.new
      request.env["HTTP_REFERER"] = '/'
      get :add_to_cart, :product_code => "Shawshank"

      assigns(:cart).cart_items.length.should == 0
      response.should redirect_to('/')
      flash[:notice].should == "Invalid Product"
    end
  end

  describe "remove_item_from_cart" do
    it "should remove the given product from the cart" do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @cart = Cart.new
      @cart.cart_items << FactoryGirl.create(:cart_item)
      request.env["HTTP_REFERER"] = '/'
      get :remove_item_from_cart, :id => @product.id

      assigns(:cart).cart_items.length.should == 0
      response.should redirect_to('/')
      flash[:notice].should == "Item removed from cart"
    end

    it "should redirect back with notice if item couldn't be removed from the cart" do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @cart = Cart.new
      @cart.cart_items << FactoryGirl.create(:cart_item)
      request.env["HTTP_REFERER"] = '/'
      get :remove_item_from_cart, :id => "BLAR"

      response.should redirect_to('/')
      flash[:notice].should == "Item could not be removed from cart. We have been notified of this issue so it can be resolved. We apologize for the inconvenience. If you need to remove this item, you may try emptying your cart. I... am so embarrassed."
    end
  end

  describe "update_item_in_cart" do
    it "should update an item in the cart" do
      @product_type2 = FactoryGirl.create(:product_type, :name => 'Models')
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @base_product = FactoryGirl.create(:product, :category_id => @category.id, :subcategory_id => @subcategory.id, :quantity => 1, :product_type_id => @product_type.id, :product_code => 'XX111')
      @product = FactoryGirl.create(:product, :category_id => @category.id, :subcategory_id => @subcategory.id, :quantity => 30, :product_type_id => @product_type2.id, :product_code => 'XX111M', :name => 'fake product')
      @cart = FactoryGirl.create(:cart)
      @cart_item = FactoryGirl.create(:cart_item, :cart_id => @cart.id)
      @cart.cart_items << @cart_item
      post :update_item_in_cart, :cart => {:item_id => @cart_item.id, :quantity => 20}
      @cart_item.reload

      @cart_item.quantity.should == 20
    end
  end

  describe "checkout" do
    it 'should redirect to guest_registration if there is no current_customer' do
      @user = FactoryGirl.create(:user)
      controller.should_receive(:current_customer).at_least(1).times.and_return(nil)
      sign_in @user
      get :checkout

      response.should redirect_to('/guest_registration')
    end

    it "should not set up a new order since the user chose paypal" do
      @user = FactoryGirl.create(:user)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @cart = Cart.new
      @cart.cart_items << FactoryGirl.create(:cart_item)
      sign_in @user
      get :checkout

      assigns(:order).should be_nil
    end

    it "should set up a new order since the user submitted an address form" do
      @user = FactoryGirl.create(:user)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @cart = Cart.new
      @cart.cart_items << FactoryGirl.create(:cart_item)
      sign_in @user
      session[:address_submitted] = {}
      session[:address_submitted][:address_submission_method] = 'form'
      get :checkout

      assigns(:order).should_not be_nil
    end

    it "should redirect back if there is nothing in the cart" do
      @user = FactoryGirl.create(:user)
      @cart = Cart.new
      request.env["HTTP_REFERER"] = '/'
      sign_in @user
      get :checkout

      response.should redirect_to('/')
      flash[:notice].should == 'Your cart is empty.'
    end

    it "should redirect to signin if there is not a user logged in" do
      @cart = Cart.new
      get :checkout

      response.should redirect_to("/users/sign_in")
    end

    it "should redirect to cart if a user has already purchased a set of instructions" do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product, :product_type_id => @product_type.id)
      @order = FactoryGirl.create(:order_with_line_items)
      @cart = FactoryGirl.create(:cart_with_cart_items, :user_id => @user.id)
      request.env["HTTP_REFERER"] = '/'
      sign_in @user
      get :checkout

      response.should redirect_to('/cart')
      flash[:notice].should == "You've already purchased the following products before, (#{@product.name}) and you don't need to do it again. Purchasing instructions once allows you to download the files #{MAX_DOWNLOADS} times."
    end

    it "should not redirect to cart if a user has added a physical product to their cart that they've purchased before" do
      @product_type2 = FactoryGirl.create(:product_type, :name => 'Models', :digital_product => false)
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      @product1 = FactoryGirl.create(:product)
      @product2 = FactoryGirl.create(:physical_product, :product_type_id => @product_type2.id)
      @order = FactoryGirl.create(:order)
      @line_item = FactoryGirl.create(:line_item, :order_id => @order.id, :product_id => @product2.id)
      @cart = FactoryGirl.create(:cart_with_cart_items, :user_id => @user.id)

      request.env["HTTP_REFERER"] = '/'
      sign_in @user
      get :checkout

      response.should_not redirect_to('/cart')
      flash[:notice].should_not == "You've already purchased the following products before, (#{@product1.name}) and you don't need to do it again. Purchasing instructions once allows you to download the files #{MAX_DOWNLOADS} times."
    end

    it "should show the flash notice notifying user of bad quantities for physical items" do
      @product_type2 = FactoryGirl.create(:product_type, :name => 'Models', :digital_product => false)
      @user = FactoryGirl.create(:user, :tos_accepted => true)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @base_product = FactoryGirl.create(:product, :category_id => @category.id, :subcategory_id => @subcategory.id, :product_type_id => @product_type.id, :name => "Winter Village Flak Cannon", :quantity => 1, :product_code => 'WV009')
      @product = FactoryGirl.create(:product, :category_id => @category.id, :subcategory_id => @subcategory.id, :product_type_id => @product_type2.id, :name => "Winter Village Flak Cannon Model", :quantity => 3, :product_code => 'WV009M')
      @cart = FactoryGirl.create(:cart)
      @cart_item = FactoryGirl.create(:cart_item, :product_id => @product.id, :cart_id => @cart.id, :quantity => 5)
      @cart.cart_items << @cart_item
      @cart.save
      session[:cart_id] = @cart.id
      sign_in @user
      session[:address_submitted] = {:address1 => '123 Fake St.'}
      get :checkout

      flash[:notice].should match("Please reduce quantities or remove")
      flash[:notice].should match("Winter Village Flak Cannon")
    end
  end

  describe "empty_cart" do
    it "should empty the cart" do
      @user = FactoryGirl.create(:user)
      @cart = Cart.new(:user_id => @user.id)
      @cart.cart_items << FactoryGirl.create(:cart_item)
      @cart.cart_items << FactoryGirl.create(:cart_item, :product_id => 2)
      @cart.save
      session[:cart_id] = @cart.id
      post :empty_cart

      Cart.all.should == []
      session[:cart_id].should be_nil
      response.should redirect_to('/store')
      flash[:notice].should == "You have emptied your cart."
    end
  end

  describe "product_details" do
    it "should return the product" do
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      get :product_details, :product_code => product.product_code, :product_name => product.name

      assigns(:product).name.should == product.name
    end
  end

  describe "submit_order" do
    it "should delete session[:guest]" do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      FactoryGirl.create(:product)
      @cart = FactoryGirl.create(:cart_with_cart_items, :user_id => @user.id)
      session[:guest] = @user.id
      post :submit_order, :order => {:user_id => @user.id}

      expect(session[:guest]).to be_nil
    end

    it "should submit the order to paypal" do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      FactoryGirl.create(:product)
      @cart = FactoryGirl.create(:cart_with_cart_items, :user_id => @user.id)
      sign_in @user
      post :submit_order, :order => {:user_id => @user.id}

      #I don't like this, but I'm not sure how else to do it.
      response.should redirect_to("https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_cart&upload=1&custom=#{assigns(:order).request_id}&business=#{ENV['BCD_PAYPAL_EMAIL']}&image_url=http://brickcitydepot.com/uploads/4/8/0/4/4804115/4994570.jpg&return=http://bcd-stg.herokuapp.com/thank_you&notify_url=http://bcd-stg.herokuapp.com/listener&currency_code=USD&item_name_1=CB001%20Colonial%20Revival%20House&amount_1=10.0&quantity_1=1")
    end

    it "should send the right quantity and amount when sending the order to paypal" do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      FactoryGirl.create(:product)
      @cart = FactoryGirl.create(:cart_with_cart_items_with_multiple_quantity, :user_id => @user.id)
      sign_in @user
      post :submit_order, :order => {:user_id => @user.id}

      #I don't like this, but I'm not sure how else to do it.
      response.should redirect_to("https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_cart&upload=1&custom=#{assigns(:order).request_id}&business=#{ENV['BCD_PAYPAL_EMAIL']}&image_url=http://brickcitydepot.com/uploads/4/8/0/4/4804115/4994570.jpg&return=http://bcd-stg.herokuapp.com/thank_you&notify_url=http://bcd-stg.herokuapp.com/listener&currency_code=USD&item_name_1=CB001%20Colonial%20Revival%20House&amount_1=10.0&quantity_1=2")
    end

    it "should redirect to cart with an 'uh-oh' message if the order couldn't be submitted" do
      @user = FactoryGirl.create(:user)
      @cart = FactoryGirl.create(:cart)
      Order.any_instance.stub(:save).and_return(false)
      sign_in @user
      post :submit_order, :order => {:user_id => @user.id}

      response.should redirect_to('/cart')
      flash[:notice].should == "Uh-oh. Something bad happened. Please try again."
    end
  end

  describe 'enter_address' do
    context "current_user & current_user has orders & address hasn't already been submitted" do
      it "should look at an existing order to get the address used on a previous order" do
        @user = FactoryGirl.create(:user)
        FactoryGirl.create(:category)
        FactoryGirl.create(:subcategory)
        FactoryGirl.create(:product)
        FactoryGirl.create(:order, :address_street_1 => '123 Fake St.', :address_state => 'VA')
        controller.should_receive(:current_user).at_least(1).times.and_return(@user)
        get :enter_address

        assigns(:order).address_state.should eq('VA')
      end
    end

    context "address has been submitted" do
      context "submission method is form" do
        it 'should create an Order object based on the submitted address' do
          session[:address_submitted] = {:address_submission_method => 'form', :address_state => 'CO'}
          get :enter_address

          assigns(:order).address_state.should eq('CO')
        end
      end

      context "submission method is not form" do
        it 'should create an empty Order object' do
          session[:address_submitted] = {:address_submission_method => 'sasquatch', :address_state => 'CA'}
          get :enter_address

          assigns(:order).should be_a_new(Order)
        end
      end
    end

    context "fall-through condition" do
      it 'should create an empty Order object' do
        get :enter_address

        assigns(:order).should be_a_new(Order)
      end
    end
  end

  describe 'validate_street_address' do
    context 'if an address is submitted via form' do
      it 'should use the address to create an Order object' do
        post :validate_street_address, :order => {:address_submission_method => 'form', :address_state => 'HI'}

        assigns(:order).address_state.should eq('HI')
      end

      context 'if order is not valid' do
        it 'should render enter_address' do
          Order.any_instance.should_receive(:valid?).at_least(1).times.and_return(false)
          post :validate_street_address, :order => {:address_submission_method => 'form', :address_state => 'NY'}

          response.should render_template(:enter_address)
        end
      end

      context 'if order is valid' do
        it 'should redirect to checkout' do
          Order.any_instance.should_receive(:valid?).at_least(1).times.and_return(true)
          post :validate_street_address, :order => {:address_submission_method => 'form', :address_state => 'ID'}

          response.should redirect_to('/checkout')
        end
      end
    end

    context 'if an address is not submitted via the form' do
      it 'should redirect to checkout' do
        post :validate_street_address, :order => {:address_submission_method => 'paypal', :address_state => 'LA'}

        response.should redirect_to('/checkout')
      end
    end
  end

  describe "products" do
    it 'should get @product_type, and @products' do
      category = FactoryGirl.create(:category)
      subcategory = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      get :products, :product_type_name => @product_type.name
      assigns(:product_type).name.should eq 'Instructions'
      assigns(:products).length.should eq 1
    end

    it 'should redirect to /store and flash a nice message if cant find a product type' do
      ProductType.should_receive(:where).and_raise(ActiveRecord::RecordNotFound)
      get :products, :product_type_name => 'fake'

      response.should redirect_to('/store')
      flash[:notice].should eq("Sorry. We don't have any of those.")
    end
  end

  describe "restock_downloads" do
    it 'should restock downloads if downloads already existed' do
      setup_products
      @user = FactoryGirl.create(:user)
      @order = FactoryGirl.create(:order)
      @download = FactoryGirl.create(:download, remaining: 1, user_id: @user.id, product_id: @product1.id)
      li1 = LineItem.new product_id: @product1.id, quantity: 1, total_price: 5
      @order.line_items << li1
      controller.send(:restock_downloads, @order)

      expect(@download.reload.remaining).to eq MAX_DOWNLOADS+1
    end

    it 'should not restock downloads if the app cannot find an existing download record' do
      setup_products
      @user = FactoryGirl.create(:user)
      @order = FactoryGirl.create(:order)
      li1 = LineItem.new product_id: @product1.id, quantity: 1, total_price: 5
      @order.line_items << li1
      Download.any_instance.should_not_receive(:restock)
      controller.send(:restock_downloads, @order)

      expect(Download.count).to eq 0
    end
  end

  describe "listener" do
    it "should save address details if order includes physical item" do
      @product_type2 = FactoryGirl.create(:product_type, :name => 'Models', :digital_product => false)
      user = FactoryGirl.create(:user)
      category = FactoryGirl.create(:category)
      subcategory = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      physical_product = FactoryGirl.create(:physical_product)
      order = FactoryGirl.create(:order, :status => '', :user_id => user.id)
      line_item = FactoryGirl.create(:line_item, :product_id => physical_product.id, :order_id => order.id)
      Order.should_receive(:find_by_request_id).at_least(:once).and_return(order)
      InstantPaymentNotification.any_instance.stub(:valid?).and_return(true)
      InstantPaymentNotification.any_instance.stub(:address_city).and_return("Richmond")
      order.should_receive(:save).at_least(1).times

      post :listener, {:custom => 'blar'}

      order.address_city.should eq("Richmond")
    end

    it "should not save address details if order does not include physical item" do
      user = FactoryGirl.create(:user)
      order = FactoryGirl.create(:order, :status => '', :user_id => user.id)
      Order.should_receive(:find_by_request_id).at_least(:once).and_return(order)
      InstantPaymentNotification.any_instance.stub(:valid?).and_return(true)
      InstantPaymentNotification.any_instance.stub(:address_city).and_return("Richmond")
      order.should_receive(:save).at_least(1).times

      post :listener, {:custom => 'blar'}

      order.address_city.should be_nil
    end

    it "should send an order confirmation email and save details to the order if the IPN is valid" do
      user = FactoryGirl.create(:user)
      order = FactoryGirl.create(:order, :status => '', :user_id => user.id)
      Order.should_receive(:find_by_request_id).at_least(:once).and_return(order)
      InstantPaymentNotification.any_instance.stub(:valid?).and_return(true)
      order.should_receive(:save).at_least(1).times
      OrderMailer.should_receive(:order_confirmation)

      post :listener, {:custom => 'blar'}

      response.should be_success
      response.body.strip.should be_empty
    end

    it "should send a guest order confirmation email and save details to the order if the IPN is valid" do
      user = FactoryGirl.create(:user,:account_status => 'G')
      order = FactoryGirl.create(:order, :status => '', :user_id => user.id)
      Order.should_receive(:find_by_request_id).at_least(:once).and_return(order)
      InstantPaymentNotification.any_instance.stub(:valid?).and_return(true)
      order.should_receive(:save).at_least(1).times
      OrderMailer.should_receive(:guest_order_confirmation)

      post :listener, {:custom => 'blar'}

      response.should be_success
      response.body.strip.should be_empty
    end

    it "should not send an order confirmation email, but save details to the order if the IPN is invalid" do
      order = FactoryGirl.create(:order, :status => '')
      Order.should_receive(:find_by_request_id).at_least(:once).and_return(order)
      InstantPaymentNotification.any_instance.stub(:valid?).and_return(false)
      order.should_receive(:save).at_least(1).times
      OrderMailer.should_not_receive(:order_confirmation)

      post :listener, {:custom => 'blar'}

      response.should be_success
      response.body.strip.should be_empty
    end

    it "should drop the request if an order can not be found by request_id" do
      order = FactoryGirl.create(:order)
      post :listener, {:custom => 'fake'}

      assigns(:order).should be_nil
      response.should be_success
      response.body.strip.should be_empty
    end

    it "should drop the request if the orders status is already set as COMPLETED" do
      order = FactoryGirl.create(:order)
      post :listener, {:custom => 'blar'} #blar is the request_id for a COMPLETED order in the order factory

      assigns(:order).should_not be_nil
      response.should be_success
      response.body.strip.should be_empty
    end
  end

  def setup_products
    @category1 = FactoryGirl.create(:category)
    @category2 = FactoryGirl.create(:category, :name => "Random Stuff")
    @category3 = FactoryGirl.create(:category, :name => 'Alternative Builds')
    @subcategory1 = FactoryGirl.create(:subcategory)
    @subcategory2 = FactoryGirl.create(:subcategory, :category_id => 2, :code => "RS")
    @subcategory3 = FactoryGirl.create(:subcategory, :category_id => @category3.id, :code => 'XV')
    @product1 = FactoryGirl.create(:product)
    @product2 = FactoryGirl.create(:product, :product_code => "XX001", :name => "Ninja Fortress", :price => 5)
    @product3 = FactoryGirl.create(:product, :product_code => 'XX002', :name => "Giant Thing", :ready_for_public => 'f', :price => 5)
    @product4 = FactoryGirl.create(:product, :product_code => 'XX003', :name => 'Gangsta Hideout', :category_id => 2, :price => 3)
    @product5 = FactoryGirl.create(:product, :product_code => 'XV001', :name => 'PeeWees Playhouse', :category_id => @category3.id, :price => 3, :alternative_build => 't')
    @product6 = FactoryGirl.create(:product, :product_code => 'XX004', :name => 'Fruitcake Palace', :price => 0, :free => 't')
  end
end
