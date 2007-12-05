class AssetMeta < ActiveRecord::Base
  belongs_to :asset

  LICENSES = {
        'by-nc-nd'=>'Attribution Non-commercial No Derivatives',
        'by-nc-sa'=>'Attribution Non-commercial Share Alike',
        'by-nc'=>'Attribution Non-commercial',
        'by-nd'=>'Attribution No Derivatives',
        'by-sa'=>'Attribution Share Alike',
        'by'=>'Attribution',
        'copyright'=>'Copyright',
        'fairuse'=>'Fair Use',
        'publicdomain'=>'Public Domain'
  }
end
