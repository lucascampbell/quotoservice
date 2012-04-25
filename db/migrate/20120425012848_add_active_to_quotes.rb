class AddActiveToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :active, :boolean, :default => false
  end
end
