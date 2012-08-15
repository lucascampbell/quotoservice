class Quote < ActiveRecord::Base
  validates :quote, :presence => true
  validates :quote, :uniqueness => { :case_sensitive => false }
  #validates :book, :presence => true
  #validates :citation, :presence => true
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :topics
  before_destroy :log_destroy
  after_update :log_update
  #after_create :log_create
  
  STARTING_ID = 1666
  self.per_page = 200
  
  def set_id
    q = Quote.last
    self.id = q.blank? ? STARTING_ID : (q.id + 1)
  end
  
  def log_update
    return unless self.active == true
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
    QuoteDelete.create!(:quote_id => self.id)
  end
  
  def log_deactivate
    qc = QuoteCreate.find_all_by_quote_id(self.id)
    qc.first.destroy if qc.first != nil
    QuoteDelete.create!(:quote_id => self.id)
  end
  
  def log_create
    qd = QuoteDelete.find_all_by_quote_id(self.id)
    qd.first.destroy if qd.first != nil
    QuoteCreate.create!(:quote_id => self.id, :active => true)
  end
end
