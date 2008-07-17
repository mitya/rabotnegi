class Salary
	@@fields = [:min, :max]
	
	# cal-seq:
	#		new 
	#		new(attributes: Hash)
	#		new(min: int, max: int, exact: int, currency: CurrencySymbol, negotiable: bool)
	def initialize(*args)
		@currency = :rub
		if args.empty?
		elsif args.first.is_a? Hash
			attributes = args.first
			attributes.each { |name, value| send("#{name}=", value) }
		else
			@min, @max = args
		end
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
		return "договорная" if negotiable?
		return swc("#{exact}")	if exact?
		return swc("от #{min}") if min?
		return swc("до #{max}") if max?
		return swc("#{min}—#{max}") if range?
	end
	
	def to_plain_text
		negotiable? ? '' : to_s
	end
	
	def for_edit
		return '' if negotiable?
		return "#{exact}"	if exact?
		return "#{min}+" if min?
		return "<#{max}" if max?
		return "#{min}-#{max}" if range?
	end
	alias text for_edit
	
	def text=(value)
	  other = parse(value)
	  min = other.min
	  max = other.max
	end
	
  # Returns a copy of self in targetCurrency
	def convert_currency(targetCurrency)
		clone.convert_currency!(targetCurrency)
	end
	
	# Converts self to targetCurrency
	def convert_currency!(targetCurrency)
		@min = CurrencyConverter.convert(@min, currency, targetCurrency) if @min
		@max = CurrencyConverter.convert(@max, currency, targetCurrency) if @max
		@currency = targetCurrency
		self
	end
		
private
	# Returns salary string with currency sign if currency is defined; otherwise--just salary.
	def salary_with_currency(salary_string)
		# "#{salary_string}#{' ' + MapService.currency_name(currency) if currency}"				
	  "#{salary_string} р."
	end 
  alias swc salary_with_currency
  
  class << self
    def parse(string_value)
  		params = {}
  		string_value.strip!
  		case string_value
  		when /(^\d+$)/
  			params[:exact] = $1.to_i
  		when /^(\d+)-(\d+)$/, /^(\d+)—(\d+)$/
  			params[:min] = $1.to_i
  			params[:max] = $2.to_i
  		when /^от (\d+)$/, /^(\d+)\+$/ 
  			params[:min] = $1.to_i
  		when /^до (\d+)$/, /^<(\d+)$/
  			params[:max] = $1.to_i
  		else
  			raise ArgumentError, "Невозможно конвертировать '#{string_value}'."
  	  end
  		new(params)
  	end	
  end
end