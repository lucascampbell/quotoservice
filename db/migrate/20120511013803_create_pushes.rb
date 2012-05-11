class CreatePushes < ActiveRecord::Migration
  def change
    create_table :pushes do |t|
      t.integer :device_id
      t.string :platform
      t.timestamps
    end
  end
end
