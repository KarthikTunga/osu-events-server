class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column :url, :string
      t.column :location, :string
      t.column :desc, :string
      t.column :category, :string
    end
  end

  def self.down
    drop_table :events
  end
end
