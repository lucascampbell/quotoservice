class Topic < ActiveRecord::Base
  validates :name, :presence => true
  validates :name, :uniqueness => { :case_sensitive => false }
  STARTING_ID = 57
  self.per_page = 200
  has_and_belongs_to_many :quotes
  before_destroy :log_destroy
  after_update :log_create
  after_create :log_create
  
  def self.topics_new(id)
    tc = TopicCreate.where("id > ?",id)
    topics = Topic.select("id,name,visible,expires_at,status,order_index").where(:id => tc.collect(&:topic_id)) unless tc.blank?
    if topics
      q_json = {:topic_create => topics,:last_id => tc.last.id}
    else
      q_json = {:topic_create =>"noupdates"}
    end
    q_json
  end
  
  def self.topics_delete(id)
    td = TopicDelete.where("id > ?",id)
    unless td.blank?
      ids = td.collect(&:topic_id).uniq
      delete = {:ids => ids, :last_id => td.last.id.to_s}
      q_json = {}
      q_json[:topic_delete] = delete
    else
      q_json = {:topic_delete => 'noupdates'}
    end
    q_json
  end
  
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

  # def log_update
  #    #TopicDelete.create!(:topic_id => self.id)
  #    TopicCreate.create!(:topic_id => self.id)
  #  end

  def log_create
    TopicCreate.create!(:topic_id => self.id)
  end
end
