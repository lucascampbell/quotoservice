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
      puts "tag found -- #{t.name}" if t
      Tag.create!(:name=>row["tag"],:visible=>row["vis"],:id=>row[index]) unless t
    end
    
  end
  
  task :load_topics do
    f = File.join(File.dirname(__FILE__),"../../public/db_topics.csv")
    csv_text = File.read(f)
    csv = CSV.parse(csv_text, :headers => true)
    csv.each_with_index do |row,index|
      row = row.to_hash.with_indifferent_access
      puts "row is -- #{row}"
      t = Topic.find_by_name(row["topic"])
      puts "topic found -- #{t.name}" if t
      Topic.create!(:name=>row["topic"],:visible=>row["vis"],:id=>row[index]) unless t
    end
  end
  
  task :load_quotes do
    f = File.join(File.dirname(__FILE__),"../../public/db_quotes.csv")
    csv_text = File.read(f)
    csv = CSV.parse(csv_text, :headers => true)
    csv.each_with_index do |row,index|
      row = row.to_hash.with_indifferent_access
      puts "row is -- #{row}"
      quote = Quote.find_by_quote(row["Quotes"])
      if(quote)
        puts "quote found -- adding new topic #{row['Topic']}"
        quote.topics << Topic.find_by_name(row["Topic"])
      else
        quote = Quote.new({
             :book        => row["Book"],
             :author      => row["Author"],
             :citation    => row["Citation"],
             :quote       => row["Quotes"],
             :rating      => row["Rate"],
             :translation => row["Translation"]
         })
         quote.id = row["ID"]
         quote.topics << Topic.find_by_name(row["Topic"])
         row["Tags"].split(',').each do |t|
           puts "tag is #{t}"
           tag = Tag.find_by_name(t)
           puts "tag is -- #{tag}"
           quote.tags << tag if tag
         end
       end
       puts "quote to save is ---- #{quote.id}"
       quote.save!
       puts "quote saved"
    end
  end
  
end