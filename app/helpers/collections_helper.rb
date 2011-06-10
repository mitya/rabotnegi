# coding: utf-8

module CollectionsHelper
	def found_objects_info(collection, word, e1, e2, e5)
		if collection.total_pages <= 1
			count = collection.size
			object = RussianInflector.inflect(collection.size, word, e1, e2, e5)
		else
			object = RussianInflector.inflect(collection.total_entries, word, e1, e2, e5)
		end

		"Найдено <b>#{collection.total_entries}</b> #{object}.
		 Показаны <b>#{collection.offset + 1}</b> — <b>#{collection.offset + collection.length}</b>".html_safe
	end
	
	def pagination(collection)
	  content_tag :div, :class => "pager" do
	    content_tag(:b, "Страницы:") + " " +
	    will_paginate(collection, :previous_label => "« предыдущая", :next_label => "следующая »")
    end if collection.total_pages > 1
	end
end
