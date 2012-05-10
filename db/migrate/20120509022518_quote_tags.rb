class QuoteTags < ActiveRecord::Migration
  def up
    create_table :quote_tags, :id => false do |t|
        t.integer :quote_id
        t.integer :tag_id            
    end
  end

  def down
    drop_table :quote_tags
  end
end
