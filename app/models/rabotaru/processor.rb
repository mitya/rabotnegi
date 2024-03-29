class Rabotaru::Processor
  attr_accessor :vacancies
  
  def initialize(options = {})
    @vacancies = []
    @work_dir = Rails.root.join("tmp", "#{Se.rabotaru_dir}-#{Mu.date_stamp}")
    @converter = Rabotaru::Converter.new
  end

  def process
    Mu.info "processing downloaded vacancies"

    read unless vacancies.any?
    remove_duplicates
    filter
    save

    Mu.event "rr-loader.processed"
  end

  def read
    Dir["#{@work_dir}/*.json"].each do |file|
      data = File.read(file).sub!(/;\s*$/, '')
      items = gg.json.decode(data)
      vacancies = items.map { |item| convert(item) }.compact
      @vacancies.concat(vacancies)
    end

    Mu.info "read files", count: @vacancies.size
  end

  def convert(item)
    @converter.convert(item)
  rescue => e
    # save error to the errors table
    Mu.alert "convert failed, item skipped #{item['position']}", reason: gg.format_error(e.message)
    nil
  end

  def remove_duplicates
    @vacancies.uniq_by! { |v| v.external_id }
    Mu.info "removed dups", count: @vacancies.size
  end
  
  def filter
    new_vacancies, updated_vacancies = [], []
    loaded_external_ids = @vacancies.map(&:external_id)
    existed_vacancies = Vacancy.any_in(external_id: loaded_external_ids)
    existed_vacancies_map = existed_vacancies.index_by(&:external_id)
    
    @vacancies.each do |loaded_vacancy|
      existed_vacancy = existed_vacancies_map[loaded_vacancy.external_id]
      if !existed_vacancy
        new_vacancies << loaded_vacancy
      elsif existed_vacancy.created_at != loaded_vacancy.created_at
        existed_vacancy.attributes = loaded_vacancy.attributes.except('_id')
        updated_vacancies << existed_vacancy
      else
        # vacancies are considered to be identical
      end
    end

    @vacancies = new_vacancies + updated_vacancies

    detalization = {}
    @vacancies.each { |v|
      detalization["#{v.city}-#{v.industry}"] ||= 0
      detalization["#{v.city}-#{v.industry}"] += 1
    }

    Mu.info new: new_vacancies.count, updated: updated_vacancies.count, total: @vacancies.count, env: detalization
  end

  def save
    @vacancies.each { |a| a.save! }
    Mu.info "stored"
  end
end
