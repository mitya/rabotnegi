# coding: utf-8
require 'test_helper'

web_test "Home" do
  test "home page" do
    visit "/"
    click_link "Поиск вакансий"
    assert_equal vacancies_path, current_path

    within '#header' do
      assert_has_link "Поиск вакансий"
      assert_has_link "Публикация вакансий"
    end

    within '#content' do
      assert_has_select "Город"
      assert_has_select "Отрасль"
      assert_has_field "Ключевые слова"
    end
  end  

  test "vacancies search" do
    click_button "Найти"
  end
end
