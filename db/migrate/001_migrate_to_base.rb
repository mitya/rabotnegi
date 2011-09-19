class MigrateToBase < ActiveRecord::Migration
	def self.up
    create_table "simple_captcha_data", :force => true do |t|
      t.string   "key",        :limit => 40
      t.string   "value",      :limit => 6
      t.datetime "created_at"
      t.datetime "updated_at"
    end
	end

	def self.down
		drop_table :simple_captcha_data
	end
end
