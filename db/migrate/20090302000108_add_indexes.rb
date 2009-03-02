class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :vacancies, [:city, :salary_min]
    add_index :vacancies, [:city, :industry, :salary_min]
  end

  def self.down
  end
end
