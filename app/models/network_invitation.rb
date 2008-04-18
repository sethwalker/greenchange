class NetworkInvitation 
  def self.spawn( message_params )
    address_text = message_params[:recipient]
    addresses = address_text.split /\s?,\s?/
    invites = addresses.inject([]) do |invites, address|
      recipient = EmailRecipient.find_or_create_by_email( address, :last_sender => current_user )
      invite = NetworkInvitation.new :recipient => recipient, :sender => current_user, :body => message_params[:body]
      NetworkInvitationMailer.deliver_invitation( invite ) if invite.valid?
      invites << invite
    end
  end

  def initialize( attributes = {} )
    @errors = []
    attributes = attributes
  end

  def attributes=( attributes = {} )
    attributes.each do |key, value|
      send("@#{key}=", value)
    end
  end

  attr_accessor :recipient, :recipients, :body, :sender

  def valid?
    begin
      validate
    rescue exception
      @errors << exception
      false
    end
  end

  def validate
    raise NoRecipientGiven unless self.recipient
    raise EmailAddressInvalid.new( self.recipient.email)  unless self.recipient.valid?
    raise DeliveryBlocked( self.recipient.email )  if self.recipient.blocked?
    true
  end


  def errors
    @errors
  end

  class EmailAddressInvalid < Exception
    def initialize(address = nil)
      @address = address
      super
    end
    def message
      "The address %s is not valid" % @address
    end
  end
  class NoRecipientGiven < Exception
    def message
      "No recipient given"
    end
  end
  class BlockRequested < EmailAddressInvalid
    def message
      "The address #{@address} has requested no further email from #{Crabgrass::Config.site_name}"
    end
  end

end
