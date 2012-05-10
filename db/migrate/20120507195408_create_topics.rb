class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name
      t.integer :visible, :default => 0
      t.timestamps
    end
  end
end
