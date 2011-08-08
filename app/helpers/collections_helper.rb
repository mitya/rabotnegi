# coding: utf-8

module CollectionsHelper
	def found_objects_info(collection, word, e1, e2, e5)
		if collection.total_pages <= 1
			count = collection.size
			object = RussianInflector.inflect(collection.size, word, e1, e2, e5)
		else
			object = RussianInflector.inflect(collection.total_count, word, e1, e2, e5)
		end

		"Найдено <b>#{collection.total_count}</b> #{object}.
		 Показаны <b>#{collection.offset + 1}</b> — <b>#{collection.offset + collection.limit_value}</b>".html_safe
	end
	
  def search_tag
    text_field = text_field_tag(:q, params[:q], type: "search", id: 'q', :class => "search", autofocus: true)
    text_field + " " + submit_tag("Поиск", name: nil)
  end

  def search_form(url)
    tg :div, "search" do
      form_tag url, method: "get" do
        search_tag
      end
    end
  end
  
  def listing(collection, &block)
    html = if collection.any?
      tg(:table, "listing", &block) + pagination(collection)
    else
      tg :div, "Ничего не найдено.", "no-data-message"
    end
    html
  end
end
