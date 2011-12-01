class ErrMailer < ActionMailer::Base
  default from: ERR_SENDER
  helper :application, :format

  def notification(err)
    @err = err
    mail to: ERR_RECIPIENTS, subject: "[rabotnegi.ru] #{@err}"
  end
end
