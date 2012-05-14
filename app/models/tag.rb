class Tag < ActiveRecord::Base
  validates :name, :presence => true
  validates :name, :uniqueness => { :case_sensitive => false }
  STARTING_ID = 1625
  has_and_belongs_to_many :quote
  
   def set_id
     t = Tag.last
     self.id = t.blank? ? STARTING_ID : (t.id + 1)
   end
end
