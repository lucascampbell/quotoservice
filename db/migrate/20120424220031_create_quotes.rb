class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.text :quote
      t.string :citation
      t.string :book
      t.boolean :favorite
      t.timestamps
    end
  end
end
