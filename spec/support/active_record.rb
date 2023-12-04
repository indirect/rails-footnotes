require "active_record"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migration.verbose = false

ActiveRecord::Migration.create_table :widgets do |t|
  t.string :name
  t.timestamps
end

class Widget < ActiveRecord::Base
end

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
