class RemoveQuoteTopicId < ActiveRecord::Migration
  def up
    remove_column :quotes, :topic_id
  end

  def down
    add_column :quotes, :topic_id, :string
  end
end
