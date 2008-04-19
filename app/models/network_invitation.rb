class NetworkInvitation 

  def initialize( attribute_values = {} )
    super()
    self.attributes = ( attribute_values )
  end

  def self.spawn( message_params )
    address_text = message_params[:recipients].gsub( /\s|\n|\t|\r/, '')
    addresses = address_text.split /,/
    invites = addresses.inject([]) do |invites, address|
      invite = NetworkInvitation.new :recipient_email  => address, :sender => message_params[:sender], :body => message_params[:body]
      invite.send_email if invite.valid?
      invites << invite
    end
  end

  def send_email
    NetworkInvitationMailer.deliver_invitation( self ) if self.valid?
  end

  attr_accessor :recipient, :recipients, :recipient_email, :body, :sender

  def attributes=( attribute_values = {} )
    attribute_values.each do |key, value|
      self.send("#{key}=".to_sym, value)
    end
  end

  def valid?
    errors.clear
    validate
    errors.empty?
  end

  def validate
    errors.add( :recipient, "is blank") and return unless self.recipient
    errors.add( :recipient, ( "address %s is not valid" % self.recipient.email) ) and return unless self.recipient.valid? 
    #raise DeliveryBlocked( self.recipient.email )  if self.recipient.blocked?
    errors.add( :recipient, "address #{self.recipient_email} has requested no further email from #{Crabgrass::Config.site_name}") and return if self.recipient.blocked?
    errors.add( :recipient, "address #{self.recipient_email} belongs to an existing member of this network") and return if ( User.find_by_email( self.recipient_email ) || Profile::EmailAddress.find_by_email_address( self.recipient_email ))
    true
  end



  def recipient_email
    recipient.email 
  end

  def recipient_email=( value )
    return value if recipient && recipient.email == value
    self.recipient = EmailRecipient.find_or_create_by_email value, :last_sender => sender
    value
  end


  def errors
    @errors ||= ActiveRecord::Errors.new(self)
  end

  def errors_on(field_name)
    errors.on(field_name)
  end
  def self.human_attribute_name(key)
    key.to_s.humanize
  end
end
