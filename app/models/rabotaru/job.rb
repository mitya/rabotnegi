module Rabotaru
  class Job < ApplicationModel
    field :state, type: Symbol, default: 'started'
    embeds_many :loadings, class_name: 'Rabotaru::Loading'
    def_state_predicates 'state', :started, :failed, :loaded, :processed
    store_in "rabotaru.jobs"

    attr_accessor :period, :queue, :current

    def run
      @period ||= 10
      @queue ||= City.all.product(Industry.all).map { |city, industry| Loading.new(city: city.key, industry: industry.key) }
      @current = queue.shift

      loop { done = tick; break if done }
    end

    def to_s
      "Rabotaru-Job(#{created_at.to_date.to_s(:long)})"
    end

    private

    def tick
      reload
      current.reload if current && current.queued?
      Log.debug "rr_scheduler: current.state=#{current.try(:state)} job.loadings.count=#{loadings.count}"
      case current.try(:state)
      when nil
        mark :loaded
        Mu.enqueue(Rabotaru, :process_loaded_vacancies, id)
        return true
      when :created
        loadings << current
        current.queue
        wait
      when :queued
        wait
        if Time.now - current.queued_at > 20.minutes
          current.mark :failed, error: "Skipped after timeout"
          @current = queue.deq
        end
      when :failed
        if loadings.select(&:failed?).count > 3
          mark :failed
          return true
        end
        @current = queue.shift
      when :done
        time_since_done = Time.now - current.done_at
        @current = queue.shift
        wait(period - time_since_done) if time_since_done < period
      end
      
      false
    end

    def wait(timeout = period)
      sleep(timeout)
    end        
  end
end
