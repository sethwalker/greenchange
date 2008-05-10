module MessageSpawner
  def distill_errors_to_singular( invalid_items, result_item )
    result_item.recipients = invalid_items.map { |m| m.recipients }.join(', ')
    invalid_recipients = []
    invalid_items.each do |invalid_item|
      invalid_item.errors.each do |attr, msg| 
        ( invalid_recipients << invalid_item.recipients ) and next if attr.to_sym == :recipient_id
        result_item.errors.add attr, msg
      end
    end
    result_item.errors.add( :recipients, "couldn't send to: " + invalid_recipients.join(', ') ) unless invalid_recipients.empty?
    result_item
  end
end
