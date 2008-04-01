# == Schema Information
# Schema version: 24
#
# Table name: avatars
#
#  id     :integer(11)   not null, primary key
#  data   :binary        
#  public :boolean(1)    
#

class Avatar < FlexImage::Model
  # limit image size to 96 x 96
  pre_process_image :size => '96x96', :crop => true
  
  def self.pixels(size)
    case size
      when 'tiny';   '12x12'
      when 'xsmall'; '22x22'
      when 'small' ; '24x24'
      when 'medium'; '48x48'
      when 'standard'; '64x64'
      when 'large' ; '96x96'
      else; '96x96'
    end
  end
  
end
