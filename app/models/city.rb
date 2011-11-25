class City < Struct.new(:code, :external_id, :name)
  cattr_reader :all

  def self.[](code)
    @@all.find { |city| city.code == code.to_sym }
  end
  singleton_class.send(:alias_method, :get, :[])
  
  def self.each(&block)
    @@all.each(&block)
  end
  
  def self.find_by_external_id(external_id)
    external_id = external_id.to_i
    city = @@all.find { |city| city.external_id == external_id } || raise(ArgumentError, "Город ##{external_id} не найден")
    city.code
  end

  def to_s
    name
  end

  def inspect
    "<City #{code}/#{external_id} #{name}>"
  end

  @@all = [
  	City.new(:msk, 1, "Москва"),
  	City.new(:spb, 2, "Санкт-Петербург"),
  	City.new(:ekb, 3, "Екатеринбург"),
  	City.new(:nn,  4, "Нижний Новгород"),
  	City.new(:nsk, 9, "Новосибирск")  
  ]
end
