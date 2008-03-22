class CollectingsController < ApplicationController #Tool::BaseController
  def index
    @collectings = Collecting.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @collectings }
      format.json { render :json => @collectings }
    end
  end

  def show
    @collecting = Collecting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @collecting }
      format.json { render :json => @collecting }
    end
  end

  def new
    @collecting = Collecting.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @collecting }
      format.json { render :json => @collecting }
    end
  end

  def edit
    @collecting = Collecting.find(params[:id])
  end

  def create
    @collecting = Collecting.new(params[:collecting])

    respond_to do |format|
      if @collecting.save
        flash[:notice] = "Item added to #{@collecting.collection.name}."
        format.html { redirect_to( :controller => 'collectings', :id => @collecting.id ) }
        format.xml  { render :xml  => @collecting, :status => :created, :location => @collecting }
        format.json { render :json => @collecting, :status => :created, :location => @collecting }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml  => @collecting.errors, :status => :unprocessable_entity }
        format.json { render :json => @collecting.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @collecting = Collecting.find(params[:id])

    respond_to do |format|
      if @collecting.update_attributes(params[:collecting])
        flash[:notice] = "Item was successfully updated."
        format.html { redirect_to( :controller => 'collectings', :id => @collecting.id ) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @collecting.errors, :status => :unprocessable_entity }
        format.json { render :json => @collecting.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @collecting = Collecting.find(params[:id])
    @collecting.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = "Item was deleted from #{@collecting.collection.name}"
        redirect_to( :controller => 'collectings', :action => 'index' )
      end 
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end

