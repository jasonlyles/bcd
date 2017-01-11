class StaticController < ApplicationController
  def index
    #session.delete(:guest_has_arrived_for_downloads)
    #session.delete(:guest) #for testing
    #reset_session #for testing
    @updates = Update.live_updates
  end

  def contact
    @email = Email.new
  end

  def maintenance
    if Switch.maintenance_mode.off?
      flash[:notice] = 'Done with maintenance!'
      redirect_to '/'
    end
  end

  # This exists only to confirm that my exception notification delivery is working. Would be nicer to perhaps hook
  # into heroku deploy to send an email through the exception notification gem to just email me during/after a deploy.
  # This will do for now.
  # /exception_notification_test
  def test_exception_notification_delivery
    1/0
  end

  def send_contact_email
    @email = Email.new(params[:email])

    if @email.valid?
      #begin
        ContactMailer.new_contact_email(@email.name, @email.email_address, @email.body).deliver
        #@email = nil
        flash[:notice] = "Thanks for your email. We'll get back with you shortly."
        redirect_to :contact
      #rescue => e

       # flash[:alert] = "Something went wrong. Please wait a moment and try again."
       # render :contact
      #end
    else
      flash[:alert] = "Uh oh. Look below to see what you need to fix."
      render :contact
    end
  end

  #Legacy routes
  def legacy_name_signs
    legacy_no_page_redirect_and_flash("Name Signs")
  end

  def legacy_custom_letters
    legacy_no_page_redirect_and_flash("Custom Letters")
  end

  def legacy_lego_prints
    legacy_no_page_redirect_and_flash("Lego Prints")
  end

  def legacy_books
    render 'books'
  end

  def legacy_instruction_sample
    render 'instruction_sample'
  end

  def legacy_menswear_instructions
    legacy_product_redirect('CB027')
  end

  def legacy_archfirm_instructions
    legacy_product_redirect('CB028')
  end

  def legacy_speakeasy_instructions
    legacy_product_redirect('CB029')
  end

  def legacy_logo_theme_sign
    legacy_no_page_redirect_and_flash("Lego Logo Theme Sign")
  end

  def legacy_city_theme_sign
    legacy_no_page_redirect_and_flash("City Theme Sign")
  end

  def legacy_friends_theme_sign
    legacy_no_page_redirect_and_flash("Friends Theme Sign")
  end

  def legacy_star_wars_theme_sign
    legacy_no_page_redirect_and_flash("Star Wars Theme Sign")
  end

  def legacy_sales_deals
    legacy_no_page_redirect_and_flash("Sales/Deals")
  end

  def legacy_lego_neighborhood_extras
    render 'lego_neighborhood_extras'
  end

  def legacy_google_hosted_service
    render 'google_hosted_service'
  end

  def legacy_gallery
    legacy_no_page_redirect_and_flash("Gallery")
  end

  def legacy_commissions
    legacy_no_page_redirect_and_flash("Commissions")
  end

  def legacy_instructions
    redirect_to :controller => :store, :action => :instructions
  end

  def legacy_contact
    @email = Email.new
    render 'contact'
  end

  def legacy_city_category
    legacy_category_redirect('City')
  end

  def legacy_winter_village_category
    legacy_category_redirect('Winter Village')
  end

  def legacy_military_category
    legacy_category_redirect('Military')
  end

  def legacy_castle_category
    legacy_category_redirect('Other')
  end

  def legacy_train_category
    legacy_category_redirect('Train')
  end

  private

  def legacy_no_page_redirect_and_flash(page_desc)
    flash[:notice] = "We don't currently have a #{page_desc} page. Please check back for an update soon."
    return redirect_to '/'
  end

  def legacy_product_redirect(product_code)
    begin
      product = Product.find_by_product_code(product_code)
     return redirect_to :controller => :store, :action => :product_details, :product_code => product.product_code, :product_name => product.name.to_snake_case
    rescue NoMethodError, ActiveRecord::RecordNotFound
      logger.error("Failed trying to get a legacy product page using product code: #{product_code}")
      flash[:notice] = "Could not find that product. Please try navigating to the product through the store"
      return redirect_to :controller => :store, :action => :instructions
    end
  end

  def legacy_category_redirect(cat_name)
    redirect_to :controller => :store, :action => :categories, :product_type_name => 'Instructions', :category_name => cat_name
  end
end
