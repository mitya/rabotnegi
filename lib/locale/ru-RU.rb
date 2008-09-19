I18n.backend.store_translations :'ru-RU', {
  :activerecord => {
    :errors => {
      :messages => {
        :inclusion => "не вкллючена в список",
        :invalid => "заполнено не верно",
        :confirmation => "не соответствует подтверждению",
        :accepted  => "должно быть принято",
        :empty => "не заполнено",
        :blank => "не заполнено",
        :taken => "уже занято",
        :not_a_number => "не число",
      },
      :template => {
        :header => {
          :one => "1 ошибка мешает сохранить {{object_name}}",
          :other => "{{count}} ошибок мешают сохранить {{object_name}}"
        },
        :body => "Есть проблемы с этими полями:",
        :default_header => "Пожалуйста заполните следующие поля:"
      }
    },
    :attributes => {
      :resume => {
        :fname        => 'Имя',
        :lname        => 'Фамилия',
        :password     => 'Пароль',
        :city         => 'Город',
        :industry     => 'Отрасль',
        :job_title    => 'Должность',
        :min_salary   => 'Зарплата',
        :job_reqs     => 'О работе',
        :about_me     => 'Обо мне',
        :contact_info => 'Контакты'
      },
      :vacancy => {
        :title         => 'Дожность',
        :description   => 'Описание',
        :external_id   => 'Внешний номер',
        :industry      => 'Отрасль',
        :city          => 'Город',
        :salary_min    => 'Зарплата от',
        :salary_max    => 'Зарплата до',
        :employer_name => 'Название работодателя'
      },
      :employer => {
        :name     => 'Название',
        :captcha  => 'Картинка',
        :password => 'Пароль',
        :login    => 'Логин'
      }
    }
  },
  :models => {
    :resume => 'резюме',
    :vacancy => 'вакансия',
    :employer => 'работодатель'    
  }
}

module I18n
  def self.use_default_locale(exception, locale, key, options)
    raise
    ActionController.Base.logger.debug("Looking en-US translation for #{key}")
    puts "Looking en-US translation for #{key}"
    if locale != default_locale
      translate(key, options.merge(:locale => default_locale))
    else
      default_exception_handler(exception, locale, key, options)
    end
  end
  
  self.exception_handler = :use_default_locale
end