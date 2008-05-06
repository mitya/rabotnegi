require 'spec/spec_helper'

# describe EmployersController do
#   integrate_views
#   fixtures :employers
#   
#   before :each do
#     @gazprom = employers(:gazprom)
#   end
#   
#   it "renders login form on GET :new" do
#     get :new
#     
#     assigns[:employer].should_exist
#     response.should be_success
#     response.should have_tag('form[action=/employers]') do
#       with_tag('input#employer_name[type=text]')
#       with_tag('input#employer_login[type=text]')
#       with_tag('input#employer_password[type=password]')
#       with_tag('input#employer_password_confirmation[type=password]')
#     end
#   end
#   
#   it "creates new employer on POST :create" do
#     post :create, :employer => {
#       :name => 'Microsoft', :login => 'ms', :password => '123', :password_confirmation => '123'
#     }
#     
#     microsoft = Employer.find_by_login('ms')
#     microsoft.should_exist
#     microsoft.name.should == 'Microsoft'
#     microsoft.password.should == '123'
# 
#     response.should redirect_to(my_vacancies_path)
#   end
#   
#   it "logs users in, when credentials are ok, on POST :log_in" do
#     post :log_in, :login => @gazprom.login, :password => @gazprom.password
#     session[:employer_id].should == @gazprom.id
#     response.should redirect_to(my_vacancies_path)
#   end
#   
#   it "doesn't log in user with wrong credentials, on POST :log_in" do
#     post :log_in, :login => 'bandito', :password => 'secreto'
#     
#     session[:employer_id].should == nil
#     flash[:error].should_exist
#     response.should render_template('index')
#   end
# end