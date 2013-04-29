require "RMagick"
require "open-uri"
class Image < ActiveRecord::Base
  ACCESS_KEY        = "AKIAIFCIXLO37BMPBVVA"#ENV["AWS_ACCESS_KEY_ID"] 
  ACCESS_PSSWRD     = "ZnMfJvlcYnvretJrEysj5ydFnP20cFtjp+8ibduP"#ENV["AWS_SECRET_ACCESS_KEY"]
  has_and_belongs_to_many :tags
  before_destroy :remove_from_s3
  before_destroy :log_destroy
  after_update :log_update
  after_create :log_create
  STARTING_ID = 37
  self.per_page = 50
  # attr_accessible :title, :body
  
  
  def self.images_new(id)
    ic     = ImageCreate.where("id > ?",id).order("id ASC")
    images = Image.select("id,name,email,description,approved_at,s3_link").where(:id => ic.collect(&:image_id)) if ic
    if images.blank?
      i_json = {:image_create =>"noupdates"}
    else
      #loop through images and insert tag ids for json resp
      i_formatted = format_images(images)
      i_json = {:image_create => i_formatted, :image_create_last_id => ic.last.id}
    end
    i_json
  end
  
  def self.images_delete(id)
    idel = ImageDelete.where("id > ?",id).order("id ASC")
    unless idel.blank?
      ids = idel.collect(&:image_id).uniq
      delete = {:ids => ids, :image_delete_last_id => idel.last.id.to_s}
      i_json = {}
      i_json[:image_delete] = delete
    else
      i_json = {:image_delete => 'noupdates'}
    end
    i_json
  end
  
  def set_id
    image = Image.last
    self.id = image.blank? ? STARTING_ID : (image.id + 1)
  end
  
  def upload_to_s3(upload)
    errors = nil
    errors = "Must be a valid .jpg file" unless upload.original_filename =~ /.jpg/
    unless errors
      s3 = AWS::S3.new(
        :access_key_id => ACCESS_KEY,
        :secret_access_key => ACCESS_PSSWRD)
    
      
      bucket = s3.buckets['goverseimages']
      file   = upload.read
      #create original
      obj1 = bucket.objects["approved/#{self.id}.jpg"]
      obj1.write(file,:acl=>:public_read)
     
      [[100,100],[320,480],[480,320],[768,1024],[1024,768],[1536,2048],[2048,1536]].each do |ary|
        obj = bucket.objects["approved/#{self.id}_#{ary[0]}x#{ary[1]}.jpg"]
        image = Magick::ImageList.new
        image.from_blob(file)
        image.resize_to_fill!(ary[0],ary[1])
        obj.write(image.to_blob,:acl=>:public_read)
      end
      
      self.s3_link = "https://s3.amazonaws.com/goverseimages/approved/#{self.id}"
      self.approved_at = Time.now
      self.active = true
      self.save!
    end
    errors
  end
  
  def self.create_device_uploaded_image(params)
    @image                  = Image.new
    @image.name             = params[:name]
    @image.device_submitted = true
    @image.device_name      = params[:device_name]
    @image.email            = params[:email]
    @image.description      = params[:description]
    @image.location         = params[:location]
    @image.s3_link          = "https://s3.amazonaws.com/goverseimages/submitted/#{params[:device_name]}.jpg"
    @image.add_tags(params[:tags]) if params[:tags]
    @image.set_id           
    @image.save!
  end
  
  def activate_s3_image
    if self.device_name
      self.move_to_approved_dir
    end
    self.active      = true
    self.s3_link     = "https://s3.amazonaws.com/goverseimages/approved/#{self.id}.jpg"
    self.device_name = nil
    self.approved_at = Time.now
    self.save!
  end
  
  def deactivate_s3_image
     self.active = false
     self.approved_at = nil
     self.save!
  end
  
  def move_to_approved_dir
    s3 = AWS::S3.new(
      :access_key_id => ACCESS_KEY,
      :secret_access_key => ACCESS_PSSWRD)
    
    bucket = s3.buckets['goverseimages']
    obj1   = bucket.objects["submitted/#{self.device_name}.jpg"]
    obj2   = bucket.objects["approved/#{self.id}.jpg"]
      
    obj1.copy_to(obj2)
    obj1.delete
      
    urlimage = open(self.s3_link)
    file     = urlimage.read
    [[100,100],[320,480],[480,320],[768,1024],[1024,768],[1536,2048],[2048,1536]].each do |ary|
      obj = bucket.objects["approved/#{self.id}_#{ary[0]}x#{ary[1]}.jpg"]
      image = Magick::ImageList.new
      image.from_blob(file)
      image.resize_to_fill!(ary[0],ary[1])
      obj.write(image.to_blob,:acl=>:public_read)
    end
  end
  
  def remove_from_s3
    if self.device_name 
      bucket = 'submitted'
      name   = self.device_name
    else
      bucket_name = 'approved'
      name   = self.id
    end
    s3 = AWS::S3.new(
      :access_key_id => ACCESS_KEY,
      :secret_access_key => ACCESS_PSSWRD)
      
    bucket = s3.buckets['goverseimages']
    obj1 = bucket.objects["#{bucket_name}/#{name}.jpg"]
    obj1.delete
    
    if bucket_name == 'approved'
      [[100,100],[320,480],[480,320],[768,1024],[1024,768],[1536,2048],[2048,1536]].each do |ary|
        obj = bucket.objects["approved/#{name}_#{ary[0]}x#{ary[1]}.jpg"]
        obj.delete if obj
      end
    end
  end
  
  def log_update
    return if self.device_name
    ImageDelete.create!(:image_id => self.id)
    ImageCreate.create!(:image_id => self.id)
  end
  
  def log_create
    return if self.device_name
    ImageCreate.create!(:image_id => self.id)
  end
  
  def log_destroy
    return if self.device_name
    ImageCreate.destroy_all("image_id = #{self.id}")
    ImageDelete.create!(:image_id => self.id)
  end
  
  def add_tags(tags)
    tags.split(",").each do |id|
      t = Tag.find(id)
      self.tags << t if t
    end
  end
  
  private
  
  def self.format_images(images)
     images.each do |img|
       t_ids  = img.tags.collect(&:id)
       img[:tag_ids] = t_ids
     end
     images
  end
  
end
