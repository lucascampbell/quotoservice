class AddVersion < ActiveRecord::Migration
  def change
    add_column :quote_creates, :version, :integer
    add_column :quote_deletes, :version, :integer
  end
end
