namespace :db do
  require File.join(File.dirname(__FILE__),'/../../config/environment')
  require 'csv' 
  
  task :load_tags do
    f = File.join(File.dirname(__FILE__),"../../public/db_tags.csv")
    csv_text = File.read(f)
    csv = CSV.parse(csv_text, :headers => true)
    csv.each_with_index do |row,index|
      row = row.to_hash.with_indifferent_access
      puts "row is -- #{row}"
      t = Tag.find_by_name(row["tag"])
      puts "tag found -- #{t}"
      Tag.create!(:name=>row["tag"],:visible=>row["vis"],:id=>row[index]) unless t
    end
    
  end
  
  task :load_topics do
    f = File.join(File.dirname(__FILE__),"../../public/db_topics.csv")
  end
  
  task :load_quotes do
    f = File.join(File.dirname(__FILE__),"../../public/db_quotes.csv")
  end
  
end