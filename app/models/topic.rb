class Topic < ActiveRecord::Base
  validates :name, :presence => true
  validates :name, :uniqueness => { :case_sensitive => false }
  STARTING_ID = 5
  has_many :quotes
  
   def set_id
     t = Topic.last
     self.id = t.blank? ? STARTING_ID : (t.id + 1)
   end
end
