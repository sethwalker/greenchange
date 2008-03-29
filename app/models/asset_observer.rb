require 'asset'
class AssetObserver < ActiveRecord::Observer

  def after_save(asset)
    update_page_type(asset) unless asset.parent_id
  end

  def update_page_type(asset)
    page_type = "Tool::#{asset.display_class}"
    Page.update_all("type = '#{page_type}'", "data_type = 'Asset' AND data_id = #{asset.id}")
#    page_type = case 
#           when asset.image?
#             'Tool::Image'
#           when asset.video?
#             'Tool::Video'
#           when asset.audio?
#             'Tool::Audio'
#           when asset.document?
#             'Tool::Document'
#           else
#             raise 'unknown asset type'
#           end
#    Page.update_all("type = '#{page_type}'", "data_type = 'Asset' AND data_id = #{asset.id}")
  end
end
