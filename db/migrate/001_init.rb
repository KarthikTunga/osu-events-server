class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column :name, :string
      t.column :start_date, :timestamp
      t.column :end_date, :timestamp
      t.column :contact_email :string
      t.column :contact_name, :string
      t.column :contact_number, :string
      t.column :category, :string
      t.column :event_type, :string
      t.column :description, :string
      t.column :event_link, :string
      t.column :details_link, :string
      t.column :location, :string
    end
  end

  def self.down
    drop_table :events
  end
end
