class SubcategoriesController < ApplicationController
  before_filter :authenticate_radmin!
  before_filter :get_categories
  layout proc{ |c| c.request.xhr? ? false : "admin" }
  # GET /subcategories
  # GET /subcategories.xml
  def index
    @subcategories = Subcategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subcategories }
    end
  end

  # GET /subcategories/1
  # GET /subcategories/1.xml
  def show
    @subcategory = Subcategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subcategory }
    end
  end

  # GET /subcategories/new
  # GET /subcategories/new.xml
  def new
    @subcategory = Subcategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subcategory }
    end
  end

  # GET /subcategories/1/edit
  def edit
    @subcategory = Subcategory.find(params[:id])
  end

  # POST /subcategories
  # POST /subcategories.xml
  def create
    @subcategory = Subcategory.new(params[:subcategory])

    respond_to do |format|
      if @subcategory.save
        format.html { redirect_to(@subcategory, :notice => 'Subcategory was successfully created.') }
        format.xml  { render :xml => @subcategory, :status => :created, :location => @subcategory }
      else
        flash[:alert] = "Subcategory was NOT created"
        format.html { render :action => "new" }
        format.xml  { render :xml => @subcategory.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subcategories/1
  # PUT /subcategories/1.xml
  def update
    @subcategory = Subcategory.find(params[:id])

    respond_to do |format|
      if @subcategory.update_attributes(params[:subcategory])
        format.html { redirect_to(@subcategory, :notice => 'Subcategory was successfully updated.') }
        format.xml  { head :ok }
      else
        flash[:alert] = "Subcategory was NOT updated."
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subcategory.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subcategories/1
  # DELETE /subcategories/1.xml
  def destroy
    @subcategory = Subcategory.find(params[:id])
    if @subcategory.products.empty?
      @subcategory.destroy
    else
      return redirect_to subcategories_url, :alert => "You can't delete this subcategory while it has products. Delete or reassign the products and try again."
    end

    respond_to do |format|
      format.html { redirect_to(subcategories_url) }
      format.xml  { head :ok }
    end
  end

  def model_code
    @model_code = Subcategory.model_code(params[:id])
    respond_to do |format|
      format.json  { render :json => @model_code.to_json }
    end
  end

  private

  def get_categories
    categories = Category.all
    @categories = []
    categories.each{|x|@categories << [x.name,x.id]}
  end
end
