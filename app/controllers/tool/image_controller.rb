class Tool::ImageController < Tool::BaseController
  def show
    @page = Tool::Image.find params[:id]
    @asset = @page.data
    render :action => '../asset/show'
  end
end
