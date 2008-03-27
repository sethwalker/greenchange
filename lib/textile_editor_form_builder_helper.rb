module TextileEditorFormBuilderHelper
  def textile_editor(method, options={})
    @template.textile_editor(@object_name, method, options.merge(:object => @object))
  end
end
ActionView::Helpers::FormBuilder.__send__ :include, TextileEditorFormBuilderHelper
