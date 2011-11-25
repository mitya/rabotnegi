# coding: utf-8

module DetailsViewHelper
  def details_view(options = {}, &block)
    tg :ul, klass: 'resource' do
      capture(DetailsViewBuilder.new(self), &block)
    end
  end

  def details_item(label, data, options = {})
    tg :li, klass: "item #{options[:klass]}".strip do
      content = data.to_s
      content = tg(:b, label, klass: 'heading') + " " + content unless options[:header] == false
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
      @template.tg(:li, klass: "actions", &block)
    end
  end
end
