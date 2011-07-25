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
		 Показаны <b>#{collection.offset + 1}</b> — <b>#{collection.offset + collection.length}</b>".html_safe
	end
	
	def pagination(collection, options = {})
    tg :div, "pager" do
      page_links(collection, options)
    end if collection.respond_to?(:total_pages) && collection.total_pages > 1
	end
	
	def page_links_model(collection)
	  links = []
	  
    total_pages = collection.total_pages
    current_page = collection.current_page
    inner_window = 2
    outer_window = 0

    window_from = current_page - inner_window
    window_to = current_page + inner_window
    
    if window_to > total_pages
      window_from -= window_to - total_pages
      window_to = total_pages
    end
    
    if window_from < 1
      window_to += 1 - window_from
      window_from = 1
      window_to = total_pages if window_to > total_pages
    end
    
    middle = window_from..window_to

    # left window
    if outer_window + 3 < middle.first # there's a gap
      left = (1..(outer_window + 1)).to_a
      left << :gap
    else # runs into visible pages
      left = 1...middle.first
    end

    # right window
    if total_pages - outer_window - 2 > middle.last # again, gap
      right = ((total_pages - outer_window)..total_pages).to_a
      right.unshift :gap
    else # runs into visible pages
      right = (middle.last + 1)..total_pages
    end
    
    links = left.to_a + middle.to_a + right.to_a
	end
	
	def page_links(collection, options = {})
    links_model = page_links_model(collection)
    
    params.merge!(options[:params]) if options[:params]
    
    links = links_model.map do |key|
      case
      when key == collection.current_page
        tg :em, key
      when key.is_a?(Numeric)
        link_to key, params.merge(page: key), :class => "num"
      when key == :gap
        tg :span, '&hellip;'.html_safe, "gap"
      end
    end.join(' ').html_safe

    if collection.first_page?
      links.insert 0, tg(:span, "&larr; предыдущая станица".html_safe, "stub")
    else
      links.insert 0, tg(:span, "&larr;".html_safe, "dir") + link_to("предыдущая станица".html_safe, params.merge(page: collection.previous_page))
    end

    if collection.last_page?
      links << tg(:span, "следующая страница &rarr;".html_safe, "stub")
    else
      links << link_to("следующая страница".html_safe, params.merge(page: collection.next_page))
      links << tg(:span, "&rarr;".html_safe, "dir")
    end    
    
    tg :div, "pagination" do
      links
    end
	end
	
  def search_tag
    text_field = text_field_tag(:q, params[:q], type: "search", id: 'q', :class => "search", autofocus: true)
    text_field + " " + submit_tag("Поиск", name: nil)
  end

  def search_form(url)
    form_tag url(:admin_vacancies), method: "get", :class => "search" do
      search_tag
    end
  end
	
end
