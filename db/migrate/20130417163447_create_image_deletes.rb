class CreateImageDeletes < ActiveRecord::Migration
  def change
    create_table :image_deletes do |t|
      t.integer :image_id
      t.timestamps
    end
  end
end
