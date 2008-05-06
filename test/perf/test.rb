require 'pp'
require 'fileutils'
require 'net/http'
require 'time'
require 'yaml'
require 'benchmark'
require 'thread'

#    Time    Size    Type         Servers Client threads
#    14ms   3.1kB    page_cache         1              4
#    35ms   3.1kB    dynamic            1              4
#    17ms   3.1kB    dynamic            1              1
#    30ms   3.1kB    action_cache     1,3              4
#    18ms   3.1kB    action_cache     1,3              1
#    35ms   3.1kB    frag_cache       1,3              4
#    18ms   3.1kB    frag_cache       1,3              1
#    84ms  19.0kB    dynamic          1,3              1
#   105ms  44.6kB    dynamic          1,3              1
#    19ms  44.6kB    page_cache       1,3              1
#    30ms  44.6kB    action_cache     1,3              1


$n = 50
$host, $port, $path = 'rabotnegi.ru', 80, '/vacancies/msk/it'
# $host, $port, $path = 'localhost', 3000, '/vacancies/msk/it'

def test_multiple_threads
	counter = 0
	mutex = Mutex.new
	testProc = lambda do
		while counter < $n
			requestNo = 0
			mutex.synchronize { counter += 1; p("##{counter}"); requestNo = counter }
			result = Net::HTTP.get_response($host, $path, $port)
			# p "Request ##{requestNo}, length = #{result.body.length}"
		end
	end
	
	threadCount = 1
	workerThreads = []
	
	startTime = Time.now
		threadCount.times do
			workerThread = Thread.new(&testProc)
			workerThreads << workerThread
		end
		workerThreads.each {|t| t.join }
	elapsedTime = Time.now - startTime
	
	p "Time #{elapsedTime / $n}"
end

def test_single_thread
	#  200ms    3.0kB     ya.ru
	#  280ms    3.5kB     google.ru
	#  340ms   27.0kB     yandex.ru
	# 1400ms  160.0kB     news.google.com
	#  100ms    1.5kB     localhost
	#  100ms    0.0kB     localhost/empty.html
	#  300ms    5.0kB     localrails/static
	#  430ms   20.0kB     localrails/vacancies/msk/it
	#  360ms    5.0kB     localrails/resumes/my


	response = nil
	time = Benchmark.realtime {
		$n.times {
			response = Net::HTTP.get_response($host, $path, $port)
			p 'n'
		}
	}

	p "Time #{time / $n}"

end

# test_single_thread
test_multiple_threads