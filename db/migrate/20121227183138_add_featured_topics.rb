class AddFeaturedTopics < ActiveRecord::Migration
  def change
    add_column :topics, :expires_at, :datetime
    add_column :topics, :status, :string
    add_column :topics, :order_index, :integer
    add_column :quotes, :order_index, :integer
  end
end
