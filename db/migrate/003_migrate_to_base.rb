class MigrateToBase < ActiveRecord::Migration
	def self.up
		create_table :employers do |t|
			t.column :name, :string, :null => false
			t.column :login, :string
			t.column :password, :string
			t.column :created_at, :timestamp, :null => false
    	t.column :updated_at, :timestamp, :null => false
		end
		add_index :employers, :login, :unique => true, :name => 'ix_employers_login'
		
		
		create_table :vacancies do |t|
			t.column :title, :string, :null=>false
			t.column :description, :text, :null=>false
			t.column :external_id, :integer
			t.column :industry, :enum, :limit=>$industry_list, :null=>false
			t.column :city, :enum, :limit=>$city_list, :null=>false
			t.column :salary_min, :integer
			t.column :salary_max, :integer
			t.column :employer_id, :integer
			t.column :employer_name, :string
			t.column :created_at, :timestamp, :null => false
	    t.column :updated_at, :timestamp, :null => false
		end
		add_index :vacancies, :external_id, :unique => true, :name => 'uq_vacancies_external_id'
		add_index :vacancies, :city, :name => 'ix_vacancies_city'
		add_index :vacancies, :industry, :name => 'ix_vacancies_industry'
		add_index :vacancies, [:city, :industry], :name => 'ix_vacancies_city_industry'
		add_foreign_key :vacancies, :employer_id, :employers
		
		
		create_table :resumes do |t|
			t.column :fname, :string, :limit=>30, :null=>false
			t.column :lname, :string, :limit=>30, :null=>false
			t.column :password, :string, :limit=>30
			t.column :city, :enum, :limit=>$city_list, :null=>false
			t.column :job_title, :string, :limit=>100, :null=>false
			t.column :industry, :enum, :limit=>$industry_list, :null=>false
			t.column :min_salary, :integer, :null=>false
			t.column :view_count, :integer, :null=>false, :default=>0
			t.column :job_reqs, :text
			t.column :about_me, :text
			t.column :contact_info, :text
			t.column :created_at, :timestamp, :null => false
	    t.column :updated_at, :timestamp, :null => false
		end		
		add_index :resumes, [:lname, :fname], :name => 'ix_resumes_lname_fname'
		add_index :resumes, :city, :name => 'ix_resumes_city'
		add_index :resumes, :industry, :name => 'ix_resumes_industry'
		add_index :resumes, [:city, :industry], :name => 'ix_resumes_city_industry'
	end

	def self.down
		drop_table :employers
		drop_table :vacancies
		drop_table :resumes
	end

private
	def self.add_foreign_key source_table, source_column, target_table
		execute "
			alter table #{source_table}
			add constraint fk_#{source_table}_#{target_table}
			foreign key (#{source_column}) references #{target_table}(id)"
	end
end