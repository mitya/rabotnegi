module CollectionsHelper
	def found_objects_info(collection, word, e1, e2, e5)
		if collection.total_pages <= 1
			count = collection.size
			object = RussianInflector.inflect(collection.size, word, e1, e2, e5)
		else
			object = RussianInflector.inflect(collection.total_entries, word, e1, e2, e5)
		end

		"Найдено <b>#{collection.total_entries}</b> #{object}.
		 Показаны <b>#{collection.offset + 1}</b> — <b>#{collection.offset + collection.length}</b>"
	end

	def sort_link(collection, label, field)
	  curfld, curdir = collection.sort_field, collection.sort_direction

	  param, sign = case when field != curfld then [field, '']
	    when curdir == :asc then ["-#{field}", '▲']
      when curdir == :desc then ["#{field}", '▼']
    end

    %{
      <a href='#{url_for(params.merge(:p => nil, :s => param))}' class='ui'>
        <span class='sort-mark'>#{sign}</span> #{label}
      </a>
    }
	end
end
