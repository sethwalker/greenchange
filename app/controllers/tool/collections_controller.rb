class Tool::CollectionsController < Tool::BaseController
  def index
    @collections = Tool::Collection.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @collections }
      format.json { render :json => @collections }
    end
  end

  def show
    @collection = Tool::Collection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @collection }
      format.json { render :json => @collection }
    end
  end

  def new
    @collection = Tool::Collection.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @collection }
      format.json { render :json => @collection }
    end
  end

  def edit
    @collection = Tool::Collection.find(params[:id])
  end

  def create
    @collection = Tool::Collection.new(params[:collection])

    respond_to do |format|
      if @collection.save
        flash[:notice] = "Collection: #{@collection.name} was successfully created."
        format.html { redirect_to( :controller => 'collections', :id => @collection.id ) }
        format.xml  { render :xml  => @collection, :status => :created, :location => collection_path(@collection) }
        format.json { render :json => @collection, :status => :created, :location => collection_path(@collection) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml  => @collection.errors, :status => :unprocessable_entity }
        format.json { render :json => @collection.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @collection = Tool::Collection.find(params[:id])

    respond_to do |format|
      if @collection.update_attributes(params[:collection])
        flash[:notice] = "Collection:  #{@collection.name} was successfully updated."
        format.html { redirect_to( :controller => 'collections', :id => @collection.id ) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @collection.errors, :status => :unprocessable_entity }
        format.json { render :json => @collection.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @collection = Tool::Collection.find(params[:id])
    @collection.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = "#{@collection.name} was deleted"
        redirect_to( :controller => 'collections', :action => 'index' )
      end 
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
