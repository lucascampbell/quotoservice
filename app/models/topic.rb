class Topic < ActiveRecord::Base
  validates :name, :presence => true
  validates :name, :uniqueness => { :case_sensitive => false }
  STARTING_ID = 57
  has_and_belongs_to_many :quotes
  before_destroy :log_destroy
  after_update :log_update
  after_create :log_create
  
  def set_id
    t = Topic.last
    self.id = t.blank? ? STARTING_ID : (t.id + 1)
  end
  
  def log_destroy
    #if you destroy topic after create look for old create and remove
    td = TopicCreate.find(:first,:conditions=>{:topic_id => self.id})
    td.destroy if td != nil
    TopicDelete.create!(:topic_id => self.id)
  end

  def log_update
    TopicUpdate.create!({
      :topic_id   => self.id,
      :name     => self.name,
      :visible  => self.visible
    })
  end

  def log_create
    TopicCreate.create!(:topic_id => self.id)
  end
end
