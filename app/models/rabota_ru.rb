module Rabotaru
  def self.run_job
    job = Job.create!
    job.run
  end

  def self.process_loaded_vacancies(job_id)
    job = Job.find(job_id)
    Processor.new.process
    job.mark :processed
  end

  def self.load_vacancies(job_id, loading_id)
    job = Job.find(job_id)
    loading = job.loadings.find(loading_id)
    loading.run
  end    
end
