# coding: utf-8

module DetailsViewHelper
  def details_view(options = {}, &block)
    teg :ul, klass: 'resource' do
      capture(DetailsViewBuilder.new(self), &block)
    end
  end

  def details_item(label, data)
    teg :li, klass: "item" do
      teg(:b, label, klass: 'heading') + " " + data.to_s
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
      @template.teg(:li, klass: "actions", &block)
    end
  end
end
