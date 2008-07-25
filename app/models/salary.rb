class Salary
	def initialize(min = nil, max = nil)
		@currency = :rub
		@min = min
		@max = max
	end
	
	attr_accessor :min, :max, :currency
	def exact?; @min && @max && @min == @max end
	def exact; @min end
	def exact=(value); @min = value; @max = value end
	def negotiable?; !@min && !@max end
	def negotiable=(value); @min = @max = nil if value end
	def min?; @min && !@max end
	def max?; @max && !@min end
	def range?; @max && @min && @max != @min end

	def ==(other)
		min == other.min && max == other.max && currency == other.currency
	end 
  alias eql? ==

	def to_s
	  case
      when negotiable? then "договорная"
      when exact? then "#{exact} р."
      when min? then "от #{min} р."
      when max? then "до #{max} р."
      when range? then "#{min}—#{max} р."
    end
	end

	def text
	  case
      when negotiable? then ""
      when exact? then "#{exact}"
      when min? then "#{min}+"
      when max? then "<#{max}"
      when range? then "#{min}-#{max}"
    end
	end
	
	def text=(value)
	  other = parse(value)
	  min = other.min
	  max = other.max
	end
	
	def convert_currency(new_currency)
		@min = CurrencyConverter.convert(@min, currency, new_currency) if @min
		@max = CurrencyConverter.convert(@max, currency, new_currency) if @max
		@currency = new_currency
		self
	end
		
  class << self
    def make(attributes)
  	  salary = new
  		attributes.each { |name, value| salary.send("#{name}=", value) }
  	end
  	    
  	def parse(string)
  		string.strip!
  		params = case string
    		when /(^\d+$)/ then { :exact => $1.to_i }
    		when /^(\d+)-(\d+)$/, /^(\d+)—(\d+)$/ then { :min => $1.to_i, :max => $2.to_i }
    		when /^от (\d+)$/, /^(\d+)\+$/ then { :min => $1.to_i }
    		when /^до (\d+)$/, /^<(\d+)$/ then { :max => $1.to_i }
    		else raise ArgumentError, "Невозможно конвертировать '#{string}'."
  	  end
  		make(params)
  	end
  end
end