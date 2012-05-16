namespace :db do
  require File.join(File.dirname(__FILE__),'/../../config/environment')
  require 'csv' 
  
  task :load_tags do
    Tag.delete_all
    f = File.join(File.dirname(__FILE__),"../../public/db_tags.csv")
    csv_text = File.read(f)
    csv = CSV.parse(csv_text, :headers => true)
    csv.each_with_index do |row,index|
      row = row.to_hash.with_indifferent_access
      puts "row is -- #{row}"
      t = Tag.find_by_name(row["tag"])
      puts "tag found -- #{t.name}" if t
      unless t
        tg = Tag.new(:name=>row["tag"],:visible=>row["vis"],:id=>index)
        tg.id = index + 1
        tg.save!
      end
    end
    
  end
  
  task :load_topics do
    Topic.delete_all
    f = File.join(File.dirname(__FILE__),"../../public/db_topics.csv")
    csv_text = File.read(f)
    csv = CSV.parse(csv_text, :headers => true)
    csv.each_with_index do |row,index|
      row = row.to_hash.with_indifferent_access
      puts "row is -- #{row}"
      t = Topic.find_by_name(row["topic"])
      puts "topic found -- #{t.name}" if t
      unless t
        tp = Topic.new(:name=>row["topic"],:visible=>row["vis"]) 
        tp.id = index + 1
        tp.save!
      end
    end
  end
  
  task :load_quotes do
    Quote.all.each{|q|q.tags.delete_all;q.topics.delete_all}
    Quote.delete_all
    f = File.join(File.dirname(__FILE__),"../../public/db_quotes.csv")
    csv_text = File.read(f)
    csv = CSV.parse(csv_text, :headers => true)
    csv.each_with_index do |row,index|
      row = row.to_hash.with_indifferent_access
      puts "row is -- #{row}"
      quote = Quote.find_by_quote(row["Quotes"])
      if(quote)
        puts "quote found -- adding new topic #{row['Topics']}"
        if row['Topics']
          topic = Topic.find_by_name(row["Topics"])
          exst  = quote.topics.collect(&:id).include? topic.id
          puts "topic #{topic.name} exst says #{exst}"
          unless exst
            quote.topics << topic
          end
        end
      else
        quote = Quote.new({
             :book         => row["Book"],
             :author       => row["Author"],
             :citation     => row["Citation"],
             :quote        => row["Quotes"],
             :rating       => row["Rate"],
             :abbreviation => row["Abbreviation"],
             :translation  => row["Translation"]
         })
         quote.id = row["ID"]
         if row['Topics']
           topic = Topic.find_by_name(row["Topics"]) 
           quote.topics << topic if topic
         end
         if row["Tags"]
           row["Tags"].split(',').each do |t|
             puts "tag is #{t}"
             tag = Tag.find_by_name(t)
             puts "tag is -- #{tag}"
             exst  = quote.tags.collect(&:id).include? tag.id if tag
             quote.tags << tag if tag and !exst
           end
        end
      end
      puts "quote to save is ---- #{quote.id}"
      quote.save!
      puts "quote saved"
    end
  end
  
  task :export_flat do
    file = File.join(File.dirname(__FILE__),"../../public/object_values.txt")
    File.open(file, 'w') do |f|
      f.puts "source_name|attrib|object|value"
      f.puts  "Live|image_count|39000000000|57|"
      f.puts  "Live|id_last|39000000000|1665|"
      object_id = 1
      Tag.all.each do |t|
        f.puts "Tag|id|#{object_id}|#{t.id}|"
        f.puts "Tag|name|#{object_id}|#{t.name.downcase}|"
        f.puts "Tag|visible|#{object_id}|#{t.visible}|"
        object_id += 1
      end
      Topic.all.each do |t|
        f.puts "Topic|id|#{object_id}|#{t.id}|"
        f.puts "Topic|name|#{object_id}|#{t.name.downcase}|"
        f.puts "Topic|visible|#{object_id}|#{t.visible}|"
        object_id += 1
      end
     
      Quote.all.each do |q|
        f.puts "Quote|id|#{object_id}|#{q.id}|"
        f.puts "Quote|quote|#{object_id}|#{q.quote}|"
        f.puts "Quote|citation|#{object_id}|#{q.citation}|"
        f.puts "Quote|book|#{object_id}|#{q.book}|"
        f.puts "Quote|rating|#{object_id}|#{q.rating}|"
        f.puts "Quote|author|#{object_id}|#{q.author}|" if q.author
        f.puts "Quote|translation|#{object_id}|#{q.translation}|" if q.translation
        f.puts "Quote|abbreviation|#{object_id}|#{q.abbreviation}|" if q.abbreviation
        q.tags.each do |t|
          object_id += 1
          f.puts "QuoteTag|quote_id|#{object_id}|#{q.id}|"
          f.puts "QuoteTag|tag_id|#{object_id}|#{t.id}|"
        end
        q.topics.each do |t|
          object_id += 1
          f.puts "QuoteTopic|quote_id|#{object_id}|#{q.id}|"
          f.puts "QuoteTopic|topic_id|#{object_id}|#{t.id}|"
        end
        object_id += 1
      end
    end
    
  end
  
end