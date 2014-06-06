class UpdatesController < ApplicationController
  before_filter :authenticate_radmin!
  skip_before_filter :find_cart
  skip_before_filter :get_categories
  skip_before_filter :set_users_referrer_code
  skip_before_filter :set_locale
  layout proc { |controller| controller.request.xhr? ? false : "admin" }

  # GET /updates
  # GET /updates.xml
  def index
    @updates = Update.order('created_at desc').page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @updates }
    end
  end

  # GET /updates/1
  # GET /updates/1.xml
  def show
    @update = Update.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @update }
    end
  end

  # GET /updates/new
  # GET /updates/new.xml
  def new
    @update = Update.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @update }
    end
  end

  # GET /updates/1/edit
  def edit
    @update = Update.find(params[:id])
  end

  # POST /updates
  # POST /updates.xml
  def create
    @update = Update.new(params[:update])

    respond_to do |format|
      if @update.save
        format.html { redirect_to(@update, :notice => 'Update was successfully created.') }
        format.xml  { render :xml => @update, :status => :created, :location => @update }
      else
        flash[:alert] = "Update was NOT created."
        format.html { render "new" }
        format.xml  { render :xml => @update.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /updates/1
  # PUT /updates/1.xml
  def update
    @update = Update.find(params[:id])

    respond_to do |format|
      if @update.update_attributes(params[:update])
        format.html { redirect_to(@update, :notice => 'Update was successfully updated.') }
        format.xml  { head :ok }
      else
        flash[:alert] = "Update was NOT updated."
        format.html { render "edit" }
        format.xml  { render :xml => @update.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /updates/1
  # DELETE /updates/1.xml
  def destroy
    @update = Update.find(params[:id])
    @update.destroy

    respond_to do |format|
      format.html { redirect_to(updates_url) }
      format.xml  { head :ok }
    end
  end
end
