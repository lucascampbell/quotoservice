class CreateTagCreates < ActiveRecord::Migration
  def change
    create_table :tag_creates do |t|
      t.integer :tag_id, :null => false
      t.timestamps
    end
  end
end
