class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def tr(property, title, content, options = {})
    label = label(property, title + ':')
    @template.trb(label, content, options)
  end
end
