require_dependency 'pages_controller'
class PagesController < ApplicationController
  @@page_classes += [Tool::News, Tool::Blog]
end
