class CreateTagDeletes < ActiveRecord::Migration
  def change
    create_table :tag_deletes do |t|
      t.integer :tag_id, :null => false
      t.timestamps
    end
  end
end
