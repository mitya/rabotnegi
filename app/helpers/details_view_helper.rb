# coding: utf-8

module DetailsViewHelper
  def details_view(options = {}, &block)
    content_tag :ul, :class => 'resource' do
      capture(DetailsViewBuilder.new(self), &block)
    end
  end

  def details_item(label, data)
    content_tag :li, :class => "item" do
      content_tag(:b, label, :class => 'heading') + " " + data.to_s
    end
  end  

  class DetailsViewBuilder
    def initialize(template)
      @template = template
    end
  
    def item(label, data = nil, &block)
      content = block_given?? @template.capture(&block) : data
      content = @template.format_data(content)
      @template.details_item(label, content)
    end
    
    def actions(&block)
      @template.content_tag(:div, :class => "actions", &block)
    end
  end
end
