class CreateTopicDeletes < ActiveRecord::Migration
  def change
    create_table :topic_deletes do |t|
      t.integer :topic_id, :null => false
      t.timestamps
    end
  end
end
