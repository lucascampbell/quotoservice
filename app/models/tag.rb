class Tag < ActiveRecord::Base
  validates :name, :presence => true
  validates :name, :uniqueness => { :case_sensitive => false }
  STARTING_ID = 807
  self.per_page = 200
  has_and_belongs_to_many :quotes
  
   def set_id
     t = Tag.last
     self.id = t.blank? ? STARTING_ID : (t.id + 1)
   end
end
