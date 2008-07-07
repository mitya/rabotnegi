# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 3) do

  create_table "employers", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "login"
    t.string   "password"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "employers", ["login"], :name => "ix_employers_login", :unique => true

  create_table "resumes", :force => true do |t|
    t.string   "fname",        :limit => 30,                 :null => false
    t.string   "lname",        :limit => 30,                 :null => false
    t.string   "password",     :limit => 30
    t.string   "city",                                       :null => false
    t.string   "job_title",    :limit => 100,                :null => false
    t.string   "industry",                                   :null => false
    t.integer  "min_salary",   :limit => 11,                 :null => false
    t.integer  "view_count",   :limit => 11,  :default => 0, :null => false
    t.text     "job_reqs"
    t.text     "about_me"
    t.text     "contact_info"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "resumes", ["lname", "fname"], :name => "ix_resumes_lname_fname"
  add_index "resumes", ["city"], :name => "ix_resumes_city"
  add_index "resumes", ["industry"], :name => "ix_resumes_industry"
  add_index "resumes", ["city", "industry"], :name => "ix_resumes_city_industry"

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vacancies", :force => true do |t|
    t.string   "title",                       :null => false
    t.text     "description",                 :null => false
    t.integer  "external_id",   :limit => 11
    t.string   "industry",                    :null => false
    t.string   "city",                        :null => false
    t.integer  "salary_min",    :limit => 11
    t.integer  "salary_max",    :limit => 11
    t.integer  "employer_id",   :limit => 11
    t.string   "employer_name"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "vacancies", ["external_id"], :name => "uq_vacancies_external_id", :unique => true
  add_index "vacancies", ["city"], :name => "ix_vacancies_city"
  add_index "vacancies", ["industry"], :name => "ix_vacancies_industry"
  add_index "vacancies", ["city", "industry"], :name => "ix_vacancies_city_industry"
  add_index "vacancies", ["employer_id"], :name => "fk_vacancies_employers"

end
