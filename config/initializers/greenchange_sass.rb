if File.exists? "#{RAILS_ROOT}/vendor/plugins/greenchange"
  greenchange_css_path = File.join(RAILS_ROOT, 'public', 'extensions', 'greenchange', 'stylesheets' )
  greenchange_sass_path = File.join(RAILS_ROOT, 'vendor', 'plugins', 'greenchange', 'public', 'stylesheets', 'sass' )
  Sass::Plugin.options[:template_location] = File.join( greenchange_sass_path  )
  Sass::Plugin.options[:css_location] = greenchange_css_path
end

