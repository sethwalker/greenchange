class EmailsController < ApplicationController
  def block
    @recipient = EmailRecipient.find_by_retrieval_code params[:retrieval_code]
    @recipient.block!
    flash.now[:notice] = "You will no longer recieve emails from #{Crabgrass::Config.site_name}"
  end
end
