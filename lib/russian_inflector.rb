module RussianInflector
	def self.inflect(number, word, end1, end2, end5, strategy = :normal)
		number_by_100 = number % 100
	  ending = case strategy
		when :normal
			case number_by_100
			when 1: end1
			when 2..4: end2
			when 5..20: end5
			else
				case number_by_100 % 10
				when 1: end1
				when 2..4: end2
				when 0, 5..9: end5
				end
			end
		when :more
			case number_by_100
			when 1: end2
			when 2..20: end5
			else
				case number_by_100 % 10
				when 1: end2
				when 0, 2..9: end5
				end
			end	
		end
		word + ending
	end	
end

if $0 == __FILE__
	1.upto(150) do |i|
		print "#{i} "
		print RussianInflector.inflect(i, 'ваканс', 'ия', 'ии', 'ий' )
		print "\n"
	end
	
	1.upto(150) do |i|
		print "более #{i} "
		print RussianInflector.inflect(i, 'ваканс', 'ия', 'ии', 'ий', :more)
		print "\n"
	end
end
