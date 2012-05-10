class Quote < ActiveRecord::Base
  validates :quote, :presence => true
  validates :quote, :uniqueness => { :case_sensitive => false }
  #validates :book, :presence => true
  #validates :citation, :presence => true
  has_and_belongs_to_many :tags
  belongs_to :topic
  
  STARTING_ID = 5
  
  def set_id
    q = Quote.last
    self.id = q.blank? ? STARTING_ID : (q.id + 1)
  end
  
  # def check_id(id)
  #     #if id already exists create new one
  #     q = Quote.find_by_id(id)
  #     if q.blank?
  #       self.id = id
  #     else
  #       self.set_id
  #     end
  #   end
end
