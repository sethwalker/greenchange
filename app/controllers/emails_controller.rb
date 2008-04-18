class EmailsController < ApplicationController
  def block
    @recipient = EmailRecipient.find params[:id]
    @recipient.block!
    flash.now[:notice] = "You will no longer recieve emails from #{Crabgrass::Config.site_name}"
  end
end
