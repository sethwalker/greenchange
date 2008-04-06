class Tool::ImageController < Tool::BaseController
  def show
    @asset = @page.data
    render :action => '../asset/show'
  end
end
