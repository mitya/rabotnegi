require 'test_helper'

unit_test Rabotaru::Job do
  test "scheduling w/o problems" do
    Rabotaru::Loader.any_instance.stubs(:load)
    Rabotaru::Processor.any_instance.stubs(:process)

    job = Rabotaru::Job.create!
    job.period = 0.001
    job.queue = %W(spb msk).product(%w(it retail)).map { |city, industry| Rabotaru::Loading.new(city: city, industry: industry) }

    job.run
    job.reload

    assert_equal :processed, job.state
    assert_equal 4, job.loadings.count
    assert_equal [:done] * 4, job.loadings.map(&:state)
  end
  
  teardown do
    Rabotaru::Loader.any_instance.unstub(:load)
    Rabotaru::Processor.any_instance.unstub(:process)
  end
end
