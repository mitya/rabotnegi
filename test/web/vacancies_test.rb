require 'test_helper'

web_test "Vacancies" do
  test "search page" do
    visit "/"

    click_link "Поиск вакансий"
    assert_equal vacancies_path, current_path
    
    within '#content' do
      assert_has_select "Город"
      assert_has_select "Отрасль"
      assert_has_field "Ключевые слова"
    end    
  end  
  
  test "vacancies search" do
    select 'Санкт-Петербург', from: 'Город'
    select 'Информационные технологии', from: 'Отрасль'
    click_button "Найти"

    within '#content' do
      assert_has_contents "Designer", "Ruby Developer", "Apple"
      assert_has_no_contents "Главбух", "Рога и Копыта"
    end
  end
end
