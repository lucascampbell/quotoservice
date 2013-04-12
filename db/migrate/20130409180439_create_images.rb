class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :name
      t.string :email
      t.text :description
      t.boolean :active, :default => false
      t.datetime :approved_at
      t.string :s3_link
      t.string :location
      t.boolean :device_submitted, :default=>false
      t.string  :device_name
      t.timestamps
    end
    create_table :images_tags, :id => false do |t|
        t.integer :image_id
        t.integer :tag_id            
    end
  end
end
