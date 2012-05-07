class Quote < ActiveRecord::Base
  validates :quote, :presence => true
  validates :quote, :uniqueness => { :case_sensitive => false }
  #validates :book, :presence => true
  #validates :citation, :presence => true
  
  STARTING_ID = 3000
  TAGS = [
          "tough stuff", "homelessness", "accidents","friends", "bosses","sports", "confidence",
          "travel", "safety", "neighbors", "stranger", "homelessness", "world", "cultures","feelings", "discouragement",
          "enemies", "hate", "goodness", "pray", "friends", "forgiveness", "family", "siblings", "anger", "abuse",
          "jealousy", "resentment","envy", "feelings", "hurt","body image", "create", "self", "self-worth","world", "social justice",
          "violence", "victim", "protection","protection", "intact", "safety", "reality","approval", "work", "jobs", "performance", 
           "school", "academics","work", "job", "inspiration", "school", "academics","education", "work", "inspiration", "creativity", "school", "academics"
          ]
          
   TOPIC = [
            "abuse","beauty","academics","addiction","body","breakups","competition","confidence","creativity","crisis","death","decisions","depression","direction",
            "drinking & drugs","environment","family","fear","forgiveness","friends","future","god","gratitude","hapiness","health","homosexuality","human rights",
            "identity","interfaith","jesus","jobs","lonliness","looks","love","manhood & womanhood","marraige","money","prayer","progress","purpose","relationship",
            "safety","self-worth","sexuality","spirituality","sports","stress","success","suicide","tragedy","world peace"
           ]
  
  def set_id
    q = Quote.last
    self.id = q.blank? ? STARTING_ID : (q.id + 1)
  end
  
  def check_id(id)
    #if id already exists create new one
    q = Quote.find_by_id(id)
    if q.blank?
      self.id = id
    else
      self.set_id
    end
  end
end
