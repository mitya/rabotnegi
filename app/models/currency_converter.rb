module CurrencyConverter
  module_function
  
	def convert(value, source_currency_sym, target_currency_sym)
		value * rate(source_currency_sym) / rate(target_currency_sym)
	end
	
	def rate(currency)
	  @@rates[currency]
	end

	@@rates = { :rub => 1, :usd => 23.5, :eur => 37	}
end