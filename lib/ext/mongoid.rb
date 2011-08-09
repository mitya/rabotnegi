module MongoidExt
  module PagedCollection
    def criteria
      @criteria || self
    end
    
    def criteria=(object)
      @criteria = object
    end
    
    def limit_value #:nodoc:
      criteria.options[:limit]
    end

    def offset_value #:nodoc:
      criteria.options[:skip]
    end

    def total_count #:nodoc:
      criteria.count
    end

    # Specify the <tt>per_page</tt> value for the preceding <tt>page</tt> scope
    #   Model.page(3).per(10)
    def per(num)
      if (n = num.to_i) <= 0
        self
      else
        limit(n).offset(offset_value / limit_value * n)
      end
    end

    # Total number of pages
    def num_pages
      (total_count.to_f / limit_value).ceil
    end
    
    alias total_pages num_pages

    # Current page number
    def current_page
      (offset_value / limit_value) + 1
    end

    # First page of the collection ?
    def first_page?
      current_page == 1
    end

    # Last page of the collection?
    def last_page?
      current_page >= num_pages
    end    
    

    # current_page - 1 or nil if there is no previous page
    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end

    # current_page + 1 or nil if there is no next page
    def next_page
      current_page < total_pages ? (current_page + 1) : nil
    end
    
  end

  module Document
    extend ActiveSupport::Concern

    included do
      def self.paginate(page_num, page_size = 10)
        criteria = page(page_num, page_size)
        results = criteria.to_a
        results.extend(MongoidExt::PagedCollection)
        results.criteria = criteria
        results
      end
      
      scope :page, proc { |page_num, page_size = 10| limit(page_size).offset(page_size * ([page_num.to_i, 1].max - 1)) } do
        include MongoidExt::PagedCollection
      end    
    end
  end
end

Mongoid::Document.send :include, MongoidExt::Document
