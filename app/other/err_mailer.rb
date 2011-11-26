class ErrMailer < ActionMailer::Base
  default from: ERR_SENDER
  helper :application  

  def notification(err)
    @err = err
    mail to: ERR_RECIPIENTS, subject: "[rabotnegi.ru] #{@err}"
  end
end
