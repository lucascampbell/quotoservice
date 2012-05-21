class ChangeJoinFields < ActiveRecord::Migration
  def up
    #drop_table :quotes_tags
    #drop_table :quotes_topics
    create_table :quotes_tags, :id => false do |t|
        t.references :quote
        t.references :tag             
    end
    create_table :quotes_topics, :id => false do |t|
        t.references :quote
        t.references :topic  
    end
    
  end

  def down
    drop_table :quotes_tags
    drop_table :quotes_topics
  end
end
