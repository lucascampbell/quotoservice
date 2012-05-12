class Quote < ActiveRecord::Base
  validates :quote, :presence => true
  validates :quote, :uniqueness => { :case_sensitive => false }
  #validates :book, :presence => true
  #validates :citation, :presence => true
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :topics
  
  STARTING_ID = 5
  
  def set_id
    q = Quote.last
    self.id = q.blank? ? STARTING_ID : (q.id + 1)
  end
  
end
