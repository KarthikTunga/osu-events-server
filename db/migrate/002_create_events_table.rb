class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column :name, :string
      t.column :date, :string
      t.column :time_start, :string
      t.column :time_end, :string
      t.column :contact_email, :string
      t.column :contact_name, :string
      t.column :contact_number, :string
      t.column :category, :string
      t.column :type, :string
      t.column :description, :string
      t.column :url, :string
    end
  end

  def self.down
    drop_table :events
  end
end
