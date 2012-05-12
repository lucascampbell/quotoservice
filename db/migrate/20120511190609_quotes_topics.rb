class QuotesTopics < ActiveRecord::Migration
  def up
     create_table :quotes_topics, :id => false do |t|
          t.integer :quote_id
          t.integer :topic_id            
      end
  end

  def down
    drop_table :quotes_topics
  end
end
