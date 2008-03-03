require 'spec/rake/spectask'
namespace :crabgrass do
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_files = FileList["#{RAILS_ROOT}/vendor/plugins/crabgrass*/spec/**/*_spec.rb"]
  end
end
