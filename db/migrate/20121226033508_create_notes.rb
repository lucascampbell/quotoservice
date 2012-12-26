class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.text :description
      t.integer :quote_id, :null => false
      t.timestamps
    end
    add_index :notes, :quote_id
  end
  
end
