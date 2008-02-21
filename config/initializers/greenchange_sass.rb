if File.exists? "#{RAILS_ROOT}/vendor/plugins/greenchange"
  greenchange_css_path = File.join(RAILS_ROOT, 'public', 'extensions', 'greenchange', 'stylesheets' )
  Sass::Plugin.options[:template_location] = File.join( greenchange_css_path, 'sass' )
  Sass::Plugin.options[:css_location] = greenchange_css_path
end

