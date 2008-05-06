module CurrencyConverter
	# call-seq: convert(value: Number, sourceCurrency: CurrencySymbol, targetCurrency: CurrencySymbol)
	def self.convert(value, sourceCurrency, targetCurrency)
		return value * rate(sourceCurrency) / rate(targetCurrency)
	end
	
	def self.rate(currency) @@rates[currency] end

	@@rates = { :rub => 1, :usd => 25, :eur => 34	}
end