module Mai
  module_function
  
  def write_file(path, data = nil)
    File.open(path, 'w') { |file| file << data }
  end
  
  def http_get(host, url)
    Net::HTTP.get(host, url)
  end
  
  def decode_json(data)
    ActiveSupport::JSON.decode(data)
  end
  
  def interpolate(template, replacements = {})
    replacements.inject(template) { |result, (key, value)| result.sub("{#{key}}", value.to_s) }
  end
  
  def timestamp_string
    time = Time.current
    time.strftime("%Y%m%d_%H%M%S_#{time.usec}")
  end
  
  def format_error(exception)
    "#{e.class} - #{e.message}"
  end  
  
  def id(array)
    results = array ? array.map(&:id) : []
    results = results.map(&:to_s) if results.first.is_a?(BSON::ObjectId)
    results
  end
  
# random things

  def unescape_action_mailer_stuff(string)
    string.gsub("&#47;", '/').gsub("&amp;", '&')    
  end  
end
