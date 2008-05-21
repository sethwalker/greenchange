require 'iconv'
class String
  def nameize
    translation_to   = 'ascii//ignore//translit'
    translation_from = 'utf-8'
    # Iconv transliteration seems to be broken right now in ruby, but
    # if it was working, this should do it.
    s = Iconv.iconv(translation_to, translation_from, self).to_s
    s = "-#{s}" if s =~ /^(\d+)$/ # don't allow all numbers
    s.gsub(/\W+/, ' ').strip.squeeze(' ').gsub(' ', '-').downcase
  end
  
end
