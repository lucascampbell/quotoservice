class QuoteUpdate < ActiveRecord::Base
  validates :quote_id, :presence => true
end
