class Quote < ActiveRecord::Base
  validates :quote, :presence => true
  validates :quote, :uniqueness => { :case_sensitive => false }
  validates :book, :presence => true
  validates :citation, :presence => true
  
end
