class CreateVacancyLoadings < ActiveRecord::Migration
  def self.up
    create_table :vacancy_loadings do |t|
      t.integer :new_count, :null => false
      t.integer :updated_count, :null => false
      t.text :details
      t.datetime :started_at
      t.datetime :finished_at
    end
  end

  def self.down
    drop_table :vacancy_loadings
  end
end
