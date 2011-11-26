module DetailsViewHelper
  def details_view(options = {}, &block)
    teg :ul, klass: 'resource' do
      capture(DetailsViewBuilder.new(self), &block)
    end
  end

  def details_item(label, data, options = {})
    teg :li, klass: "item #{options[:klass]}".strip do
      content = data.to_s
      content = teg(:b, label, klass: 'heading') + " " + content unless options[:header] == false
      content
    end
  end  

  class DetailsViewBuilder
    def initialize(template)
      @template = template
    end
  
    def item(label, data = nil, options = {}, &block)
      content = block_given?? @template.capture(&block) : data
      content = @template.format_data(content)
      @template.details_item(label, content, options)
    end
    
    def actions(&block)
      @template.teg(:li, klass: "actions", &block)
    end
  end
end
