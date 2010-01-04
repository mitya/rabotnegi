module ControllerHelper
  def employer_home_path
    current_employer? ? employer_vacancies_path : employer_root_path
  end
end
