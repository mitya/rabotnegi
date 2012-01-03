require 'test_helper'

unit_test RabotaRu::Job do
  test "scheduling w/o problems" do
    RabotaRu::VacancyLoader.any_instance.stubs(:load)
    RabotaRu::VacancyProcessor.any_instance.stubs(:process)

    job = RabotaRu::Job.create!
    job.period = 0.001
    job.queue = %W(spb msk).product(%w(it retail)).map { |city, industry| RabotaRu::Loading.new(city: city, industry: industry) }

    job.run
    job.reload

    assert_equal :processed, job.state
    assert_equal 4, job.loadings.count
    assert_equal [:done] * 4, job.loadings.map(&:state)
  end
  
  teardown do
    RabotaRu::VacancyLoader.any_instance.unstub(:load)
    RabotaRu::VacancyProcessor.any_instance.unstub(:process)
  end
end
