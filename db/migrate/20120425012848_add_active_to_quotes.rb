class AddActiveToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :active, :boolean, :default => 0
  end
end
