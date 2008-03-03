class Tool::ExternalVideoController < Tool::BaseController
  def create
    @page_class = Tool::ExternalVideo
    return unless request.post?
    @page = build_new_page
    @page.data = ExternalMedia::Youtube.new(params[:external_media])
    if @page.save
      return redirect_to(page_url(@page))
    else
      message :object => @page
    end
#    type = params[:type]
#    if type && klass = const_defined?("ExternalMedia::#{type.camelize}")
#      embed = klass.sanitize(params[:embed])
#    end
  end
end
