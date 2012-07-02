class CreateQuoteDeletes < ActiveRecord::Migration
  def change
    create_table :quote_deletes do |t|
      t.integer :quote_id, :null => false
      t.timestamps
    end
  end
end
