namespace :db do
  require 'csv' 
  
  task :load_tags do
    require File.join(File.dirname(__FILE__),'/../../config/environment')
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
    require File.join(File.dirname(__FILE__),'/../../config/environment')
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
    require File.join(File.dirname(__FILE__),'/../../config/environment')
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
          topic = Topic.find_by_name(row["Topics"].strip)
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
           topic = Topic.find_by_name(row["Topics"].strip) 
           quote.topics << topic if topic
         end
         if row["Tags"]
           row["Tags"].split(',').each do |t|
             puts "tag is #{t}"
             tag = Tag.find_by_name(t.strip)
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
    require File.join(File.dirname(__FILE__),'/../../config/environment')
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
        qt = q.quote.gsub!("\n",'')
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
  
  task :copy_quotes do
    require File.join(File.dirname(__FILE__),'/../../config/environment')
    Quote.all.each do |q|
      q.update_attribute(:quote_push, q.quote)
    end
  end
  
  task :create_notes do
    require File.join(File.dirname(__FILE__),'/../../config/environment')
    Quote.all.each do |q|
      Note.create!({:quote_id=>q.id})
    end
  end
  
  task :create_images do
    require File.join(File.dirname(__FILE__),'/../../config/environment')
    (1..36).each do |i|
      image             = Image.new
      image.active      = true
      image.approved_at = Time.now
      image.s3_link     = "https://s3.amazonaws.com/goverseimages/approved/#{i}.jpg"
      image.id          = i
      image.save!
      puts "finished creating image with id #{i}"
    end
  end
  
  
  task :move_images do 
    require File.join(File.dirname(__FILE__),'/../../config/environment')
    require 'open-uri'
    ACCESS_KEY        = ENV["AWS_ACCESS_KEY_ID"] 
    ACCESS_PSSWRD     = ENV["AWS_SECRET_ACCESS_KEY"]
    s3 = AWS::S3.new(
      :access_key_id => ACCESS_KEY,
      :secret_access_key => ACCESS_PSSWRD)
    bucket = s3.buckets['goverseimages']
    (2..36).each do |i|
      img = Image.find(i)
      img.s3_link = img.s3_link.gsub(".jpg","")
      img.save
      urlimage = open(img.s3_link + ".jpg")
      file     = urlimage.read
      [[100,100],[320,480],[480,320],[768,1024],[1024,768],[1536,2048],[2048,1536]].each do |ary|
        obj = bucket.objects["approved/#{img.id}_#{ary[0]}x#{ary[1]}.jpg"]
        image = Magick::ImageList.new
        image.from_blob(file)
        image.resize_to_fill!(ary[0],ary[1])
        obj.write(image.to_blob,:acl=>:public_read)
      end
    end
  end
end