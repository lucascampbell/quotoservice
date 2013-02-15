class Tag < ActiveRecord::Base
  validates :name, :presence => true
  validates :name, :uniqueness => { :case_sensitive => false }
  STARTING_ID = 807
  self.per_page = 200
  has_and_belongs_to_many :quotes
  before_destroy :log_destroy
  after_update :log_update
  after_create :log_create
   
  def self.tags_new(id)
    tc = TagCreate.where("id > ?",id)
    tags = Tag.select("id,name,visible").where(:id => tc.collect(&:tag_id)) unless tc.blank?
    if tags
      q_json = {:tag_create => tags,:last_id => tc.last.id}
    else
      q_json = {:tag_create =>"noupdates"}
    end
    q_json
  end
  
  def self.tags_delete(id)
    td = TagDelete.where("id > ?",id)
    unless td.blank?
      ids = td.collect(&:tag_id).uniq.join(',')
      delete = {:ids => ids, :last_id => td.last.id.to_s}
      q_json = {}
      q_json[:tag_delete] = delete
    else
      q_json = {:tag_delete => 'noupdates'}
    end
    q_json
  end 
   
  def set_id
    t = Tag.last
    self.id = t.blank? ? STARTING_ID : (t.id + 1)
  end
   
  def log_destroy
    #if you destroy topic after create look for old create and remove
    td = TagCreate.find(:first,:conditions=>{:tag_id => self.id})
    td.destroy if td != nil
    TagDelete.create!(:tag_id => self.id)
  end

  def log_update
    TagDelete.create!(:tag_id => self.id)
    TagCreate.create!(:tag_id => self.id)
  end

  def log_create
    TagCreate.create!(:tag_id => self.id)
  end
end
