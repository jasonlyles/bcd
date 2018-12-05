require 'spec_helper'

describe StoreController do
  before do
    @product_type = FactoryGirl.create(:product_type)
  end

  describe 'GET cart' do
    it 'should render the cart page' do
      get :cart

      expect(response).to render_template('cart')
    end

    it 'should add errant items to flash notice' do
      @product_type2 = FactoryGirl.create(:product_type, name: 'Models', digital_product: false)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @base_product = FactoryGirl.create(:product, category_id: @category.id, subcategory_id: @subcategory.id, product_type_id: @product_type.id, name: 'Winter Village Flak Cannon', quantity: 1, product_code: 'WV009')
      @product = FactoryGirl.create(:product, category_id: @category.id, subcategory_id: @subcategory.id, product_type_id: @product_type2.id, name: 'Winter Village Flak Cannon Model', quantity: 3, product_code: 'WV009M')
      @cart = FactoryGirl.create(:cart)
      @cart_item = FactoryGirl.create(:cart_item, product_id: @product.id, cart_id: @cart.id, quantity: 5)
      @cart.cart_items << @cart_item
      @cart.save
      session[:cart_id] = @cart.id
      get :cart

      expect(flash[:notice]).to match('Please reduce quantities or remove')
      expect(flash[:notice]).to match('Winter Village Flak Cannon')
    end
  end

  describe 'categories' do
    it 'should redirect to index and flash a message if category cant be found in the database' do
      setup_products
      get :categories, product_type_name: 'Instructions', category_name: 'Junk'

      expect(flash[:notice]).to eq('Sorry. That product category does not exist.')
      expect(response).to redirect_to('/store')
    end

    it 'given a category name it should find all products for sale in a category' do
      setup_products
      get :categories, product_type_name: 'Instructions', category_name: 'City'

      expect(assigns(:products).size).to eq(2)
    end

    it 'should get only alternatives when searching on alternatives' do
      setup_products
      get :categories, product_type_name: 'Instructions', category_name: 'Alternatives'

      expect(assigns(:products).size).to eq(1)
    end

    it 'should get all products for a given price group when searching for products at that price' do
      setup_products
      get :categories, product_type_name: 'Instructions', category_name: 'group_on_price', price: '5'

      expect(assigns(:products).size).to eq(1)
      expect(assigns(:category).name).to eq('$5 instructions')

      get :categories, product_type_name: 'Instructions', category_name: 'group_on_price', price: '3'

      expect(assigns(:products).size).to eq(2)
      expect(assigns(:category).name).to eq('$3 instructions')

      get :categories, product_type_name: 'Instructions', category_name: 'group_on_price', price: '7.34'

      expect(assigns(:products).size).to eq(0)
      expect(assigns(:category).name).to eq('$7.34 instructions')
    end

    it 'should get all free products when searching for freebies' do
      setup_products
      get :categories, product_type_name: 'Instructions', category_name: 'group_on_price', price: 'free'

      expect(assigns(:products).size).to eq(1)
      expect(assigns(:category).name).to eq('Completely FREE Instructions!')
    end
  end

  describe 'add_to_cart' do
    it 'should not add to cart if the item is a freebie' do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:free_product)
      @cart = Cart.new
      request.env['HTTP_REFERER'] = '/'
      post :add_to_cart, product_code: @product.product_code

      expect(assigns(:cart).cart_items.size).to eq(0)
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq("You don't need to add free instructions to your cart. Just go to your account page to download them.")
    end

    it 'should add an item to the cart' do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @cart = Cart.new
      request.env['HTTP_REFERER'] = '/'
      post :add_to_cart, product_code: @product.product_code

      expect(assigns(:cart).cart_items.size).to eq(1)
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq('Item added to cart.')
    end

    it 'should not add to cart if the item is already in the cart' do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product, product_type_id: @product_type.id)
      @cart = Cart.new
      request.env['HTTP_REFERER'] = '/'
      post :add_to_cart, product_code: @product.product_code
      post :add_to_cart, product_code: @product.product_code

      expect(assigns(:cart).cart_items.size).to eq(1)
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq("You already have #{@product.name} in your cart. You don't need to purchase more than 1 set of the same instructions.")
    end

    it 'should redirect back with a nasty notice if an invalid product code is passed in' do
      @cart = Cart.new
      request.env['HTTP_REFERER'] = '/'
      post :add_to_cart, product_code: 'Shawshank'

      expect(assigns(:cart).cart_items.size).to eq(0)
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq('Invalid Product')
    end
  end

  describe 'remove_item_from_cart' do
    it 'should remove the given product from the cart' do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @cart = FactoryGirl.create(:cart_with_cart_items)
      session[:cart_id] = @cart.id
      request.env['HTTP_REFERER'] = '/'
      get :remove_item_from_cart, id: @product.id

      expect(assigns(:cart).cart_items.size).to eq(0)
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq('Item removed from cart')
    end

    it "should redirect back with notice if item couldn't be removed from the cart" do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @cart = Cart.new
      @cart.cart_items << FactoryGirl.create(:cart_item)
      request.env['HTTP_REFERER'] = '/'
      get :remove_item_from_cart, id: 'BLAR'

      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq('Item could not be removed from cart. We have been notified of this issue so it can be resolved. We apologize for the inconvenience. If you need to remove this item, you may try emptying your cart. I... am so embarrassed.')
    end
  end

  describe 'update_item_in_cart' do
    it 'should update an item in the cart' do
      @product_type2 = FactoryGirl.create(:product_type, name: 'Models')
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @base_product = FactoryGirl.create(:product, category_id: @category.id, subcategory_id: @subcategory.id, quantity: 1, product_type_id: @product_type.id, product_code: 'XX111')
      @product = FactoryGirl.create(:product, category_id: @category.id, subcategory_id: @subcategory.id, quantity: 30, product_type_id: @product_type2.id, product_code: 'XX111M', name: 'fake product')
      @cart = FactoryGirl.create(:cart)
      session[:cart_id] = @cart.id
      @cart_item = FactoryGirl.create(:cart_item, cart_id: @cart.id, product_id: @product.id)
      @cart.cart_items << @cart_item
      post :update_item_in_cart, cart: { item_id: @cart_item.id, quantity: 20 }
      @cart_item.reload

      expect(flash[:notice]).to eq('Cart Updated')
      expect(@cart_item.quantity).to eq(20)
    end

    it 'should not update an item in the cart if the quantity is not available' do
      @product_type2 = FactoryGirl.create(:product_type, name: 'Models')
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @base_product = FactoryGirl.create(:product, category_id: @category.id, subcategory_id: @subcategory.id, quantity: 1, product_type_id: @product_type.id, product_code: 'XX111')
      @product = FactoryGirl.create(:product, category_id: @category.id, subcategory_id: @subcategory.id, quantity: 30, product_type_id: @product_type2.id, product_code: 'XX111M', name: 'fake product')
      @cart = FactoryGirl.create(:cart)
      @cart_item = FactoryGirl.create(:cart_item, cart_id: @cart.id)
      @cart.cart_items << @cart_item
      post :update_item_in_cart, cart: { item_id: @cart_item.id, quantity: 20 }
      @cart_item.reload

      expect(flash[:notice]).to eq('Sorry. There is only 1 available for XX111 Colonial Revival House. Please reduce quantities or remove the item(s) from you cart.')
      expect(@cart_item.quantity).to eq(1)
    end
  end

  describe 'checkout' do
    it 'should redirect to guest_registration if there is no current_customer' do
      @user = FactoryGirl.create(:user)
      @cart = FactoryGirl.create(:cart, user_id: nil)
      session[:cart_id] = @cart.id
      expect(controller).to receive(:current_customer).at_least(1).times.and_return(nil)
      sign_in @user
      get :checkout

      expect(response).to redirect_to('/guest_registration')
    end

    it 'should not set up a new order since the user chose paypal' do
      @user = FactoryGirl.create(:user)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @cart = FactoryGirl.create(:cart_with_cart_items)
      session[:cart_id] = @cart.id
      sign_in @user
      get :checkout

      expect(assigns(:order)).to be_nil
    end

    it 'should set up a new order since the user submitted an address form' do
      @user = FactoryGirl.create(:user)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @cart = FactoryGirl.create(:cart_with_cart_items)
      session[:cart_id] = @cart.id
      sign_in @user
      session[:address_submitted] = {}
      session[:address_submitted][:address_submission_method] = 'form'
      get :checkout

      expect(assigns(:order)).to_not be_nil
    end

    it 'should redirect back if there is nothing in the cart' do
      @user = FactoryGirl.create(:user)
      @cart = FactoryGirl.create(:cart)
      session[:cart_id] = @cart.id
      request.env['HTTP_REFERER'] = '/'
      sign_in @user
      get :checkout

      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq('Your cart is empty.')
    end

    it 'should redirect to signin if there is not a user logged in' do
      @cart = Cart.new
      get :checkout

      expect(response).to redirect_to('/users/sign_in')
    end

    it "should redirect to cart if a user has already purchased a set of instructions and hasn't downloaded yet" do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product, product_type_id: @product_type.id)
      @order = FactoryGirl.create(:order_with_line_items)
      @cart = FactoryGirl.create(:cart_with_cart_items, user_id: @user.id)
      request.env['HTTP_REFERER'] = '/'
      sign_in @user
      get :checkout

      expect(response).to redirect_to('/cart')
      expect(flash[:notice]).to eq("You've already purchased the following products before, (#{@product.name}) and you don't need to do it again. Purchasing instructions once allows you to download the files #{MAX_DOWNLOADS} times.")
    end

    it 'should redirect to cart if a user has already purchased a set of instructions and has downloaded, but downloads remaining is > 0' do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product, product_type_id: @product_type.id)
      @download = FactoryGirl.create(:download, product_id: @product.id, user_id: @user.id, remaining: 1)
      @order = FactoryGirl.create(:order_with_line_items)
      @cart = FactoryGirl.create(:cart_with_cart_items, user_id: @user.id)
      request.env['HTTP_REFERER'] = '/'
      sign_in @user
      get :checkout

      expect(response).to redirect_to('/cart')
      expect(flash[:notice]).to eq("You've already purchased the following products before, (#{@product.name}) and you don't need to do it again. Purchasing instructions once allows you to download the files #{MAX_DOWNLOADS} times.")
    end

    it 'should not redirect to cart if a user has already purchased a set of instructions, but has 0 downloads remaining' do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product, product_type_id: @product_type.id)
      @download = FactoryGirl.create(:download, product_id: @product.id, user_id: @user.id, remaining: 0)
      @order = FactoryGirl.create(:order_with_line_items)
      @cart = FactoryGirl.create(:cart_with_cart_items, user_id: @user.id)
      request.env['HTTP_REFERER'] = '/'
      sign_in @user
      get :checkout

      expect(response).to render_template(:checkout)
    end

    it "should not redirect to cart if a user has added a physical product to their cart that they've purchased before" do
      @product_type2 = FactoryGirl.create(:product_type, name: 'Models', digital_product: false)
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      @product1 = FactoryGirl.create(:product)
      @product2 = FactoryGirl.create(:physical_product, product_type_id: @product_type2.id)
      @order = FactoryGirl.create(:order)
      @line_item = FactoryGirl.create(:line_item, order_id: @order.id, product_id: @product2.id)
      @cart = FactoryGirl.create(:cart_with_cart_items, user_id: @user.id)

      request.env['HTTP_REFERER'] = '/'
      sign_in @user
      get :checkout

      expect(response).to_not redirect_to('/cart')
      expect(flash[:notice]).to_not eq("You've already purchased the following products before, (#{@product1.name}) and you don't need to do it again. Purchasing instructions once allows you to download the files #{MAX_DOWNLOADS} times.")
    end

    it 'should show the flash notice notifying user of bad quantities for physical items' do
      @product_type2 = FactoryGirl.create(:product_type, name: 'Models', digital_product: false)
      @user = FactoryGirl.create(:user, tos_accepted: true)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @base_product = FactoryGirl.create(:product, category_id: @category.id, subcategory_id: @subcategory.id, product_type_id: @product_type.id, name: 'Winter Village Flak Cannon', quantity: 1, product_code: 'WV009')
      @product = FactoryGirl.create(:product, category_id: @category.id, subcategory_id: @subcategory.id, product_type_id: @product_type2.id, name: 'Winter Village Flak Cannon Model', quantity: 3, product_code: 'WV009M')
      @cart = FactoryGirl.create(:cart)
      @cart_item = FactoryGirl.create(:cart_item, product_id: @product.id, cart_id: @cart.id, quantity: 5)
      @cart.cart_items << @cart_item
      @cart.save
      session[:cart_id] = @cart.id
      sign_in @user
      session[:address_submitted] = { address1: '123 Fake St.' }
      get :checkout

      expect(flash[:notice]).to match('Please reduce quantities or remove')
      expect(flash[:notice]).to match('Winter Village Flak Cannon')
    end
  end

  describe 'empty_cart' do
    it 'should empty the cart' do
      @cart = FactoryGirl.create(:cart_with_cart_items)
      session[:cart_id] = @cart.id
      post :empty_cart

      expect(@cart.cart_items).to eq([])
      expect(session[:cart_id]).not_to be_nil
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq('You have emptied your cart.')
    end
  end

  describe 'product_details' do
    it 'should return the product' do
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      get :product_details, product_code: product.product_code, product_name: product.name

      expect(assigns(:product).name).to eq(product.name)
    end

    it 'should return a 404 if the product cannot be found' do
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      get :product_details, product_code: 'Fake', product_name: 'Fake'

      expect(response.code).to eq('404')
    end
  end

  describe 'submit_order' do
    it 'should set a cookie for redirecting to the thank_you page' do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      FactoryGirl.create(:product)
      @cart = FactoryGirl.create(:cart_with_cart_items, user_id: @user.id)
      sign_in @user
      post :submit_order, order: { user_id: @user.id }

      expect(response.cookies['show_thank_you']).to eq('true')
    end

    it 'should immediately dump a user back to /cart if there is no @cart' do
      @user = FactoryGirl.create(:user)
      session[:guest] = @user.id
      post :submit_order, order: { user_id: @user.id }

      expect(response).to redirect_to '/cart'
    end

    it 'should not delete session[:guest]' do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      FactoryGirl.create(:product)
      @cart = FactoryGirl.create(:cart_with_cart_items, user_id: @user.id)
      session[:guest] = @user.id
      post :submit_order, order: { user_id: @user.id }

      expect(session[:guest]).to eq 1
    end

    it 'should submit the order to paypal' do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      FactoryGirl.create(:product)
      @cart = FactoryGirl.create(:cart_with_cart_items, user_id: @user.id)
      sign_in @user
      post :submit_order, order: { user_id: @user.id }

      # I don't like this, but I'm not sure how else to do it.
      expect(response).to redirect_to("https://#{ENV['BCD_PAYPAL_HOST']}/cgi-bin/webscr?cmd=_cart&upload=1&custom=#{assigns(:order).request_id}&business=#{ENV['BCD_PAYPAL_EMAIL']}&image_url=#{Rails.application.config.web_host}/assets/logo140x89.png&return=#{ENV['BCD_PAYPAL_RETURN_URL']}&notify_url=#{ENV['BCD_PAYPAL_NOTIFY_URL']}&currency_code=USD&item_name_1=CB001%20Colonial%20Revival%20House&amount_1=10.0&quantity_1=1")
    end

    it 'should send the right quantity and amount when sending the order to paypal' do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      FactoryGirl.create(:product)
      @cart = FactoryGirl.create(:cart_with_cart_items_with_multiple_quantity, user_id: @user.id)
      sign_in @user
      post :submit_order, order: { user_id: @user.id }

      # I don't like this, but I'm not sure how else to do it.
      expect(response).to redirect_to("https://#{ENV['BCD_PAYPAL_HOST']}/cgi-bin/webscr?cmd=_cart&upload=1&custom=#{assigns(:order).request_id}&business=#{ENV['BCD_PAYPAL_EMAIL']}&image_url=#{Rails.application.config.web_host}/assets/logo140x89.png&return=#{ENV['BCD_PAYPAL_RETURN_URL']}&notify_url=#{ENV['BCD_PAYPAL_NOTIFY_URL']}&currency_code=USD&item_name_1=CB001%20Colonial%20Revival%20House&amount_1=10.0&quantity_1=2")
    end

    it "should redirect to cart with an 'uh-oh' message if the order couldn't be submitted" do
      @user = FactoryGirl.create(:user)
      @cart = FactoryGirl.create(:cart)
      session[:cart_id] = @cart.id
      expect_any_instance_of(Order).to receive(:save!).and_return(false)
      sign_in @user
      post :submit_order, order: { user_id: @user.id }

      expect(response).to redirect_to('/cart')
      expect(flash[:notice]).to eq('Uh-oh. Something bad happened. Please try again.')
    end
  end

  describe 'enter_address' do
    context "current_user & current_user has orders & address hasn't already been submitted" do
      it 'should look at an existing order to get the address used on a previous order' do
        @user = FactoryGirl.create(:user)
        FactoryGirl.create(:category)
        FactoryGirl.create(:subcategory)
        FactoryGirl.create(:product)
        FactoryGirl.create(:order, address_street_1: '123 Fake St.', address_state: 'VA')
        expect(controller).to receive(:current_user).at_least(1).times.and_return(@user)
        get :enter_address

        expect(assigns(:order).address_state).to eq('VA')
      end
    end

    context 'address has been submitted' do
      context 'submission method is form' do
        it 'should create an Order object based on the submitted address' do
          session[:address_submitted] = { address_submission_method: 'form', address_state: 'CO' }
          get :enter_address

          expect(assigns(:order).address_state).to eq('CO')
        end
      end

      context 'submission method is not form' do
        it 'should create an empty Order object' do
          session[:address_submitted] = { address_submission_method: 'sasquatch', address_state: 'CA' }
          get :enter_address

          expect(assigns(:order)).to be_a_new(Order)
        end
      end
    end

    context 'fall-through condition' do
      it 'should create an empty Order object' do
        get :enter_address

        expect(assigns(:order)).to be_a_new(Order)
      end
    end
  end

  describe 'validate_street_address' do
    context 'if an address is submitted via form' do
      it 'should use the address to create an Order object' do
        post :validate_street_address, order: { address_submission_method: 'form', address_state: 'HI' }

        expect(assigns(:order).address_state).to eq('HI')
      end

      context 'if order is not valid' do
        it 'should render enter_address' do
          expect_any_instance_of(Order).to receive(:valid?).at_least(1).times.and_return(false)
          post :validate_street_address, order: { address_submission_method: 'form', address_state: 'NY' }

          expect(response).to render_template(:enter_address)
        end
      end

      context 'if order is valid' do
        it 'should redirect to checkout' do
          expect_any_instance_of(Order).to receive(:valid?).at_least(1).times.and_return(true)
          post :validate_street_address, order: { address_submission_method: 'form', address_state: 'ID' }

          expect(response).to redirect_to('/checkout')
        end
      end
    end

    context 'if an address is not submitted via the form' do
      it 'should redirect to checkout' do
        post :validate_street_address, order: { address_submission_method: 'paypal', address_state: 'LA' }

        expect(response).to redirect_to('/checkout')
      end
    end
  end

  describe 'products' do
    it 'should not get @products if product_type is Instructions' do
      category = FactoryGirl.create(:category)
      subcategory = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      get :products, product_type_name: @product_type.name
      expect(assigns(:product_type).name).to eq('Instructions')
      expect(assigns(:products)).to be_nil
    end

    it 'should get @products if product_type is not Instructions' do
      @product_type = FactoryGirl.create(:product_type, name: 'Models')
      category = FactoryGirl.create(:category)
      subcategory = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product, product_code: 'CB001')
      product2 = FactoryGirl.create(:product, product_type_id: @product_type.id, product_code: 'CB001M', name: 'The Model')
      get :products, product_type_name: 'Models'
      expect(assigns(:product_type).name).to eq('Models')
      expect(assigns(:products).size).to eq(1)
    end
  end

  describe 'thank_you_for_your_order' do
    it 'should delete the show_thank_you cookie' do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      FactoryGirl.create(:product)
      FactoryGirl.create(:order_with_line_items)
      cookies[:show_thank_you] = true
      get :thank_you_for_your_order

      expect(response.cookies['show_thank_you']).to be_nil
    end

    it 'should delete session[:guest]' do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      FactoryGirl.create(:product)
      FactoryGirl.create(:order_with_line_items)
      session[:guest] = @user.id
      get :thank_you_for_your_order

      expect(session[:guest]).to eq nil
    end

    it 'should set up @download_link' do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      FactoryGirl.create(:subcategory)
      FactoryGirl.create(:product)
      FactoryGirl.create(:order_with_line_items)
      session[:guest] = @user.id
      get :thank_you_for_your_order

      expect(assigns(:download_link)).to eq 'http://localhost:3000/guest_downloads?tx_id=blarney&conf_id=blar'
    end
  end

  def setup_products
    @category1 = FactoryGirl.create(:category)
    @category2 = FactoryGirl.create(:category, name: 'Random Stuff')
    @category3 = FactoryGirl.create(:category, name: 'Alternative Builds')
    @subcategory1 = FactoryGirl.create(:subcategory)
    @subcategory2 = FactoryGirl.create(:subcategory, category_id: 2, code: 'RS')
    @subcategory3 = FactoryGirl.create(:subcategory, category_id: @category3.id, code: 'XV')
    @product1 = FactoryGirl.create(:product)
    @product2 = FactoryGirl.create(:product, product_code: 'XX001', name: 'Ninja Fortress', price: 5)
    @product3 = FactoryGirl.create(:product, product_code: 'XX002', name: 'Giant Thing', ready_for_public: 'f', price: 5)
    @product4 = FactoryGirl.create(:product, product_code: 'XX003', name: 'Gangsta Hideout', category_id: 2, price: 3)
    @product5 = FactoryGirl.create(:product, product_code: 'XV001', name: 'PeeWees Playhouse', category_id: @category3.id, price: 3, alternative_build: 't')
    @product6 = FactoryGirl.create(:product, product_code: 'XX004', name: 'Fruitcake Palace', price: 0, free: 't')
  end
end
