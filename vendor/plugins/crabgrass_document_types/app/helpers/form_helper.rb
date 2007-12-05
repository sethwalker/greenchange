module FormHelper
  def label_for(object, field, label)
    "<label for='#{object}[#{field}]'>#{label}</label>"
  end
end
