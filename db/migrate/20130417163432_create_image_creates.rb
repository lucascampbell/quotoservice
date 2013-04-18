class CreateImageCreates < ActiveRecord::Migration
  def change
    create_table :image_creates do |t|
      t.integer :image_id
      t.timestamps
    end
  end
end
