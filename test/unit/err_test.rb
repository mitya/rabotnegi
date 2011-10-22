require 'test_helper'

unit_test Err do
  SAMPLE_ERROR_DATA = {
      controller: "vacancies", 
      action: "show", 
      url: "http://rabotnegi.test/vacancies/1234", 
      verb: "GET",
      host: "rabotnegi.test", 
      time: Time.now,
      session: {session_var_1: 100, session_var_2: 200}, 
      params: {parameter_1: 'parameter_1_value'}, 
      exception_class: 'ApplicationError',
      exception_message: "test error message",
      cookies: ["uid"],
      backtrace: "stack line 1\nstack line 2\nstack line 3",
      request_headers: {'Header-1' => '100', 'Header-2' => '200'},
      response_headers: {}          
    }

  setup do
    ActionMailer::Base.deliveries.clear
    Err.delete_all
  end
  
  test "register an error" do
    err = Err.register(SAMPLE_ERROR_DATA)
    
    assert_equal 1, Err.count
    assert_equal "test error message", Err.last.exception_message
    assert_emails 1
    assert_match "test error message", ActionMailer::Base.deliveries.last.subject
  end

  test "register an error when there were enoutht other errors this hour" do
    MAX_ERR_NOTIFICATIONS_PER_HOUR.times { Err.create!(SAMPLE_ERROR_DATA) }
    
    err = Err.register(SAMPLE_ERROR_DATA)
    assert_equal MAX_ERR_NOTIFICATIONS_PER_HOUR + 1, Err.count
    assert_emails 0
  end
end
