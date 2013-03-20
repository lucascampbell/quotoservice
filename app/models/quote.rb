class Quote < ActiveRecord::Base
  validates :quote, :presence => true
  validates :quote, :uniqueness => { :case_sensitive => false }
  #validates :book, :presence => true
  #validates :citation, :presence => true
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :topics
  has_one :note
  before_destroy :log_destroy
  after_update :log_update
  after_create :create_note
  
  STARTING_ID = 1666
  self.per_page = 100
  
  #active is used for old version of app where updates are done with separate QuoteUpdate model.  active is set to true only on creates so that old 
  #version can query for only updates that are done by create and not update.  New version should not search with active as criteria.  Bug was found recently.
  def self.quotes_new(id)
    qc     = QuoteCreate.where("id > ?",id).order("id ASC")
    quotes = Quote.select("id,quote,citation,book,active,translation,rating,author,order_index").where(:id => qc.collect(&:quote_id)) if qc
    if quotes.blank?
      q_json = {:quote_create =>"noupdates",:id => nil}
    else
      #loop through quotes and insert tag ids for json resp.  DEPRECATION WARNING is thrown, alternative is to overwrite json method 
      q_formatted = format_quotes(quotes)
      q_json = {:quote_create => q_formatted, :last_id => qc.last.id}
    end
    q_json
  end
  
  def self.resembles_base64?(quote)
    res = quote =~ /^[A-Za-z0-9+\/=]+\Z/
    (quote.length % 4 == 0) and (res != nil)
  end
  
  def self.quotes_delete(id)
    qd = QuoteDelete.where("id > ?",id).order("id ASC")
    unless qd.blank?
      ids = qd.collect(&:quote_id).uniq
      delete = {:ids => ids, :last_id => qd.last.id.to_s}
      q_json = {}
      q_json[:quote_delete] = delete
    else
      q_json = {:quote_delete => 'noupdates'}
    end
    q_json
  end
  
  def self.quotes_all
    quotes = Quote.select("id,quote,citation,book,active,translation,rating,author,order_index").where(:active=>true)
    q_formatted = format_quotes(quotes)
    qc = QuoteCreate.last ? QuoteCreate.last.id : 0
    qd = QuoteDelete.last ? QuoteDelete.last.id : 0
    {:quotes => q_formatted, :quote_create_last_id =>qc , :quote_delete_last_id => qd}
  end
  
  def self.format_quotes(quotes)
    quotes.each do |qt|
      t_ids  = qt.tags.collect(&:id)
      tp_ids = qt.topics.collect(&:id)
      qt[:tag_ids] = t_ids
      qt[:topic_ids] = tp_ids
    end
    quotes
  end
  
  def create_note
    Note.create!({:quote_id => self.id})
  end
  
  def set_id
    q = Quote.last
    self.id = q.blank? ? STARTING_ID : (q.id + 1)
  end
  
  def valiate_fields
    self.quote and self.citation and self.translation and self.book
  end
  
  def log_update
    return unless self.active == true
    QuoteDelete.create!(:quote_id => self.id)
    QuoteCreate.create!(:quote_id => self.id)
    
    #do this for 1.0 until it is deprecated
    qu = QuoteUpdate.new
    qu.quote_id = self.id
    qu.quote = self.quote if self.quote_changed?
    qu.citation = self.citation if self.citation_changed?
    qu.book = self.book if self.book_changed?
    qu.author = self.author if self.author_changed?
    qu.translation = self.translation if self.translation_changed?
    qu.abbreviation = self.abbreviation if self.abbreviation_changed?
    qu.rating = self.rating if self.rating_changed?
    qu.active = self.active if self.active_changed?
    qu.tags = self.tags.collect(&:id).join(',') if self.tags
    qu.topics = self.topics.collect(&:id).join(',') if self.topics
    qu.save
  end
  
  def log_destroy
    return unless self.active == true
    QuoteCreate.destroy_all("quote_id = #{self.id}")
    QuoteDelete.create!(:quote_id => self.id,:version=>1)
  end
  
  def log_deactivate
    QuoteCreate.destroy_all("quote_id = #{self.id}")
    QuoteDelete.create!(:quote_id => self.id,:version=>1)
  end
  
  def log_create
    qd = QuoteDelete.find(:all,:conditions=>{:quote_id => self.id})
    qd.first.destroy if qd.first != nil
    QuoteCreate.create!(:quote_id => self.id, :active => true,:version=>1)
  end
end
