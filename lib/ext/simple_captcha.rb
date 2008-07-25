module SimpleCaptcha::ModelHelpers::InstanceMethods
  def save_with_captcha!
    save_with_captcha || raise(ActiveRecord::RecordInvalid.new(self))
  end
end