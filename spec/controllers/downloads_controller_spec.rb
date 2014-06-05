require 'spec_helper'

describe DownloadsController do
  before do
    @product_type = FactoryGirl.create(:product_type)
  end

  describe "download_parts_list" do
    it "should not let someone off the street download a parts list" do
      get "download_parts_list", :parts_list_id => 1

      response.should redirect_to '/users/sign_in'
    end

    it "should not let a user download parts lists for instructions they haven't paid for" do
      @user ||= FactoryGirl.create(:user)
      sign_in(@user)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @parts_list = FactoryGirl.create(:html_parts_list)
      @order = FactoryGirl.create(:order_with_line_items)
      @product2 = FactoryGirl.create(:product, :product_code => 'GG001', :name => "Green Giant")
      @parts_list2 = FactoryGirl.create(:html_parts_list, :product_id => @product2.id)
      get "download_parts_list", :parts_list_id => @parts_list2.id

      flash[:alert].should == "Nice try. You can buy instructions for this model on this page, and then you can download the parts lists."
      response.should redirect_to '/GG001/green_giant'
    end

    it "should not allow a user to download a freebie parts list, if they have not previously ordered something" do
      @user ||= FactoryGirl.create(:user)
      sign_in(@user)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:free_product)
      @parts_list = FactoryGirl.create(:html_parts_list)
      get "download_parts_list", :parts_list_id => @parts_list.id

      flash[:alert].should == "You need to have ordered something first, before you can get these free instructions."
      response.should redirect_to "/CB001/colonial_revival_house"
    end

    it "should allow a user to download a freebie parts list, if they have ordered something" do
      @user ||= FactoryGirl.create(:user)
      sign_in(@user)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @parts_list = FactoryGirl.create(:html_parts_list)
      @order = FactoryGirl.create(:order_with_line_items)
      @free_product = FactoryGirl.create(:free_product, :product_code => 'ZZ001', :name => 'Caddzilla')
      @parts_list2 = FactoryGirl.create(:html_parts_list, :product_id => @free_product.id)
      Amazon::Storage.any_instance.stub(:connect)
      Amazon::Storage.any_instance.stub(:authenticated_url).and_return("http://s3.amazonaws.com/brickcitydepot-instructions-dev/Users/jasonlyles/src/rails_projects/brick-city/public/parts_lists/name/#{@free_product.id}/856f9442-8f75-11e2-9947-10ddb1fffe81-test.html?AWSAccessKeyId=AKIAIWLHNJ7QZL6PJIKA&Expires=1363574868&Signature=fxY32jifkkRbxxPyTfHILNjjOKc%3D")
      Amazon::Storage.any_instance.stub(:disconnect)

      get "download_parts_list", :parts_list_id => @parts_list2.id

      #Instead of trying to match where we get redirected to, I'm just matching against response.header["Location"],
      # which is where we're getting redirected to anyways
      response.header["Location"].should include "s3.amazonaws.com/brickcitydepot-instructions-dev"
      response.header["Location"].should include "/#{@free_product.id}/"
      response.header["Location"].should include ".html"
    end

    it "should allow a user to download a parts list for a product they have paid for" do
      @user ||= FactoryGirl.create(:user)
      sign_in(@user)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @parts_list = FactoryGirl.create(:html_parts_list)
      @order = FactoryGirl.create(:order_with_line_items)
      Amazon::Storage.any_instance.stub(:connect)
      Amazon::Storage.any_instance.stub(:authenticated_url).and_return("http://s3.amazonaws.com/brickcitydepot-instructions-dev/Users/jasonlyles/src/rails_projects/brick-city/public/parts_lists/#{@product.id}/856f9442-8f75-11e2-9947-10ddb1fffe81-test.html?AWSAccessKeyId=AKIAIWLHNJ7QZL6PJIKA&Expires=1363574868&Signature=fxY32jifkkRbxxPyTfHILNjjOKc%3D")
      Amazon::Storage.any_instance.stub(:disconnect)

      get "download_parts_list", :parts_list_id => @parts_list.id

      #Instead of trying to match where we get redirected to, I'm just matching against response.header["Location"],
      # which is where we're getting redirected to anyways
      response.header["Location"].should include "s3.amazonaws.com/brickcitydepot-instructions-dev"
      response.header["Location"].should include "/#{@product.id}/"
      response.header["Location"].should include ".html"
    end
  end

  describe "guest_download_parts_list" do
    context 'user has not arrived at this url legitimately' do
      it 'should flash them a notice and move them along' do
        get :guest_download_parts_list, :parts_list_id => '4', :order_id => '4545'

        flash[:notice].should eq('Sorry, you need to have come to the site legitimately to be able to download parts lists.')
        response.should redirect_to('/')
      end
    end

    context 'user who was a guest when placing an order has switched to being a regular account' do
      it 'should include freebies' do
        session[:guest_has_arrived_for_downloads] = true
        @user = FactoryGirl.create(:user, :account_status => 'A')
        @category = FactoryGirl.create(:category)
        @subcategory = FactoryGirl.create(:subcategory)
        @parts_list = FactoryGirl.create(:html_parts_list)
        @product = FactoryGirl.create(:free_product)
        @order = FactoryGirl.create(:order_with_line_items, :user_id => @user.id)
        get :guest_download_parts_list, :parts_list_id => @parts_list.id, :order_id => @order.id

        assigns(:freebies).should_not be_nil
      end
    end

    context 'user who is a guest' do
      it 'should not include freebies' do
        session[:guest_has_arrived_for_downloads] = true
        @user = FactoryGirl.create(:user, :account_status => 'G')
        @category = FactoryGirl.create(:category)
        @subcategory = FactoryGirl.create(:subcategory)
        @parts_list = FactoryGirl.create(:html_parts_list)
        @product = FactoryGirl.create(:free_product)
        @order = FactoryGirl.create(:order_with_line_items, :user_id => @user.id)
        get :guest_download_parts_list, :parts_list_id => @parts_list.id, :order_id => @order.id

        assigns(:freebies).should be_nil
      end
    end

    context 'guest is trying to download freebie parts list' do
      it 'should flash a "Sorry" alert and redirect to /' do
        session[:guest_has_arrived_for_downloads] = true
        @user = FactoryGirl.create(:user, :account_status => 'G')
        @category = FactoryGirl.create(:category)
        @subcategory = FactoryGirl.create(:subcategory)
        @parts_list = FactoryGirl.create(:html_parts_list)
        @product = FactoryGirl.create(:free_product)
        @order = FactoryGirl.create(:order_with_line_items, :user_id => @user.id)
        get :guest_download_parts_list, :parts_list_id => @parts_list.id, :order_id => @order.id

        flash[:alert].should eq('Sorry, free instructions are only available to non-guests.')
        response.should redirect_to('/')
      end
    end

    context 'products belonging to user doesnt include the product belonging to the parts list' do
      it 'should flash a "nice try" alert and redirect to the product page' do
        session[:guest_has_arrived_for_downloads] = true
        @user = FactoryGirl.create(:user, :account_status => 'G')
        @category = FactoryGirl.create(:category)
        @subcategory = FactoryGirl.create(:subcategory)
        @parts_list = FactoryGirl.create(:html_parts_list, :product_id => 5000)
        @product = FactoryGirl.create(:free_product)
        @product2 = FactoryGirl.create(:product, :id => 5000, :product_code => 'MV900', :name => 'Blarney Stone')
        @order = FactoryGirl.create(:order_with_line_items, :user_id => @user.id)
        get :guest_download_parts_list, :parts_list_id => @parts_list.id, :order_id => @order.id

        flash[:alert].should eq('Nice try. You can buy instructions for this model on this page, and then you can download the parts lists.')
        response.should redirect_to('/MV900/blarney_stone')
      end
    end

    context 'all the stars have aligned' do
      it 'should allow a download' do
        session[:guest_has_arrived_for_downloads] = true
        @user = FactoryGirl.create(:user, :account_status => 'A')
        @category = FactoryGirl.create(:category)
        @subcategory = FactoryGirl.create(:subcategory)
        @parts_list = FactoryGirl.create(:html_parts_list)
        @product = FactoryGirl.create(:free_product)
        @order = FactoryGirl.create(:order_with_line_items, :user_id => @user.id)
        Amazon::Storage.any_instance.stub(:connect)
        Amazon::Storage.any_instance.stub(:authenticated_url).and_return("http://s3.amazonaws.com/brickcitydepot-instructions-dev/Users/jasonlyles/src/rails_projects/brick-city/public/parts_lists/#{@product.id}/856f9442-8f75-11e2-9947-10ddb1fffe81-test.html?AWSAccessKeyId=AKIAIWLHNJ7QZL6PJIKA&Expires=1363574868&Signature=fxY32jifkkRbxxPyTfHILNjjOKc%3D")
        Amazon::Storage.any_instance.stub(:disconnect)
        get :guest_download_parts_list, :parts_list_id => @parts_list.id, :order_id => @order.id

        response.header["Location"].should include "s3.amazonaws.com/brickcitydepot-instructions-dev"
        response.header["Location"].should include "/#{@product.id}/"
        response.header["Location"].should include ".html"
      end
    end
  end

  describe "guest_downloads" do
    context 'transaction ID and/or request ID  params are blank' do
      it 'should redirect to download_link_error' do
        get :guest_downloads, :tx_id => '12344'

        response.should redirect_to('/download_link_error')

        get :guest_downloads, :conf_id => '12344'

        response.should redirect_to('/download_link_error')
      end
    end

    context 'cannot find order by transaction ID and request ID' do
      it 'should redirect to download_link_error' do
        get :guest_downloads, :tx_id => '12344', :conf_id => '344124'
        assigns(:order).should be_nil

        response.should redirect_to('/download_link_error')
      end
    end

    context 'everything is happy' do
      it 'should render guest_downloads' do
        @order = FactoryGirl.create(:order, :transaction_id => '12345', :request_id => '67890')
        get :guest_downloads, :tx_id => '12345', :conf_id => '67890'

        assigns(:download_links).should_not be_nil
        response.should render_template(:guest_downloads)
      end
    end
  end

  describe "guest_download" do
    context 'user guid and/or download token are blank' do
      it 'should redirect to download_error' do
        get :guest_download, :id => '12345'

        response.should redirect_to('/download/error')

        get :guest_download, :token => '12345'

        response.should redirect_to('/download/error')
      end
    end

    context 'cannot find user by guid' do
      it 'should redirect to download_error' do
        get :guest_download, :id => '234234', :token => '1234234'

        response.should redirect_to('/download/error')
      end
    end

    context 'cannot find a download by user id and/or download token' do
      it 'should redirect to download_error' do
        @user = FactoryGirl.create(:user, :guid => '12345')
        @download = FactoryGirl.create(:download, :download_token => '6789')
        get :guest_download, :id => '12345', :token => '67890'

        assigns(:download).should be_nil
        response.should redirect_to('/download/error')
      end
    end

    context 'finds a download record' do
      context 'but downloads_remaining == 0' do
        it 'should redirect to / and flash a message about having reached max downloads' do
          @user = FactoryGirl.create(:user, :guid => '12345')
          @category = FactoryGirl.create(:category)
          @subcategory = FactoryGirl.create(:subcategory)
          @product = FactoryGirl.create(:product)
          @download = FactoryGirl.create(:download, :download_token => '67890', :remaining => 0)
          User.stub(:where).and_return([@user])
          get :guest_download, :id => '12345', :token => '67890'

          assigns(:download).should_not be_nil
          flash[:notice].should eq('You have already reached your maximum allowed number of downloads for these instructions.')
          response.should redirect_to('/')
        end
      end

      context 'everything is happy' do
        it 'should allow a download' do
          @user = FactoryGirl.create(:user, :guid => '12345')
          @category = FactoryGirl.create(:category)
          @subcategory = FactoryGirl.create(:subcategory)
          @product = FactoryGirl.create(:product)
          @download = FactoryGirl.create(:download, :download_token => '67890', :remaining => 2)
          User.stub(:where).and_return([@user])
          Amazon::Storage.any_instance.stub(:connect)
          Amazon::Storage.any_instance.stub(:authenticated_url).and_return("http://s3.amazonaws.com/brickcitydepot-instructions-dev/Users/jasonlyles/src/rails_projects/brick-city/public/parts_lists/#{@product.id}/856f9442-8f75-11e2-9947-10ddb1fffe81-test.html?AWSAccessKeyId=AKIAIWLHNJ7QZL6PJIKA&Expires=1363574868&Signature=fxY32jifkkRbxxPyTfHILNjjOKc%3D")
          Amazon::Storage.any_instance.stub(:disconnect)
          get :guest_download, :id => '12345', :token => '67890'

          response.header["Location"].should include "s3.amazonaws.com/brickcitydepot-instructions-dev"
          response.header["Location"].should include "/#{@product.product_code}/"
          response.header["Location"].should include ".pdf"
        end
      end
    end
  end

  describe "download" do
    it "should not let someone off the street download" do
      get "download", :product_code => 'fake'

      response.should redirect_to '/users/sign_in'
    end

    it "should not let a user download instructions they haven't paid for" do
      @user ||= FactoryGirl.create(:user)
      sign_in(@user)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @order = FactoryGirl.create(:order_with_line_items)
      @product2 = FactoryGirl.create(:product, :product_code => 'GG001', :name => "Green Giant")
      get "download", :product_code => @product2.product_code

      flash[:alert].should == "Nice try. You can buy instructions for this model on this page, and then you can download them."
      response.should redirect_to '/GG001/green_giant'
    end

    it "should redirect back if user has used up their downloads" do
      @user ||= FactoryGirl.create(:user)
      sign_in(@user)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @order = FactoryGirl.create(:order_with_line_items)
      DownloadsController.any_instance.stub(:get_users_downloads_remaining).and_return(0)
      request.env["HTTP_REFERER"] = '/account'
      get "download", :product_code => @product.product_code

      flash[:notice].should include 'You have already reached your maximum allowed number of downloads'
      response.should redirect_to '/account'
    end

    it "should redirect to an S3 url for a pdf" do
      @user ||= FactoryGirl.create(:user)
      sign_in(@user)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @order = FactoryGirl.create(:order_with_line_items)
      Amazon::Storage.any_instance.stub(:connect)
      Amazon::Storage.any_instance.stub(:authenticated_url).and_return("http://s3.amazonaws.com/brickcitydepot-instructions-dev/Users/jasonlyles/src/rails_projects/brick-city/public/pdfs/City/Vehicles/#{@product.product_code}/856f9442-8f75-11e2-9947-10ddb1fffe81-test.pdf?AWSAccessKeyId=AKIAIWLHNJ7QZL6PJIKA&Expires=1363574868&Signature=fxY32jifkkRbxxPyTfHILNjjOKc%3D")
      Amazon::Storage.any_instance.stub(:disconnect)
      get "download", :product_code => @product.product_code

      #Instead of trying to match where we get redirected to, I'm just matching against response.header["Location"],
      # which is where we're getting redirected to anyways
      response.header["Location"].should include "s3.amazonaws.com/brickcitydepot-instructions-dev"
      response.header["Location"].should include @product.product_code
      response.header["Location"].should include ".pdf"
    end

    it "should increment the download count" do
      @user ||= FactoryGirl.create(:user)
      sign_in(@user)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @order = FactoryGirl.create(:order_with_line_items)
      Amazon::Storage.any_instance.stub(:connect)
      Amazon::Storage.any_instance.stub(:authenticated_url)
      Amazon::Storage.any_instance.stub(:disconnect)
      get "download", :product_code => @product.product_code

      download = Download.find_by_user_id_and_product_id(@user.id,@product.id)
      download.count.should == 1
    end
  end

  describe "get_users_downloads_remaining" do
    it "should get the number of downloads remaining for the given user" do
      @user = FactoryGirl.create(:user)
      category1 = FactoryGirl.create(:category)
      subcategory1 = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @order = FactoryGirl.create(:order_with_line_items)
      @download = Download.new(:user_id => @user.id, :product_id => @product.id, :remaining => 3)
      @download.save!
      sign_in @user

      controller.send(:get_users_downloads_remaining, @product.id).should == 3
    end
  end
end
