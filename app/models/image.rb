require 'aws/s3'
require "RMagick"
class Image < ActiveRecord::Base
  include AWS::S3
  BUCKET_APPROVED   = 'goverseimages/approved'
  BUCKET_SUBMITTED  = 'goverseimages/submitted'
  ACCESS_KEY        = ENV["AWS_ACCESS_KEY_ID"] #AKIAIFCIXLO37BMPBVVA
  ACCESS_PSSWRD     = ENV["AWS_SECRET_ACCESS_KEY"] #"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"
  has_and_belongs_to_many :tags
  before_destroy :remove_from_s3
  STARTING_ID = 37
  self.per_page = 100
  # attr_accessible :title, :body
  
  def set_id
    image = Image.last
    self.id = image.blank? ? STARTING_ID : (image.id + 1)
  end
  
  def upload_to_s3(upload)
    errors = nil
    errors = "Must be a valid .jpg file" unless upload.original_filename =~ /.jpg/
    unless errors
      AWS::S3::Base.establish_connection!(
        :access_key_id      => ACCESS_KEY,
        :secret_access_key  => ACCESS_PSSWRD
      )
    
      #TODO 
      #add image magick resize and landscape/portrait views
      S3Object.store("#{self.id}.jpg", upload.read, BUCKET_APPROVED, :access => :public_read)
      self.s3_link = "https://s3.amazonaws.com/goverseimages/approved/#{self.id}.jpg"
      self.approved_at = Time.now
      self.active = true
      self.save!
    end
    errors
  end
  
  def self.create_device_uploaded_image(params)
    @image                = Image.new
    @image.name           = params[:name]
    @image.device_created = true
    @image.device_name    = params[:device_name]
    @image.email          = params[:email]
    @image.description    = params[:description]
    @image.save!
    
    @image.move_to_approved_dir
  end
  
  def activate_s3_image
    if self.device_name
      self.move_to_approved_dir
    end
    self.active = true
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
    AWS::S3::Base.establish_connection!(
          :access_key_id      => ACCESS_KEY,
          :secret_access_key  => ACCESS_PSSWRD
        )
    s3 = AWS::S3.new

    bucket1 = s3.buckets[BUCKET_SUBMITTED]
    bucket2 = s3.buckets[BUCKET_APPROVED]
    obj1 = bucket1.objects["#{self.device_name}.jpg"]
    obj2 = bucket2.objects["#{self.id}.jpg"]

    obj1.copy_to(obj2)
    
    self.update_attributes({:s3_link=>"https://s3.amazonaws.com/goverseimages/approved/#{self.id}.jpg"})
  end
  
  def remove_from_s3
    AWS::S3::Base.establish_connection!(
          :access_key_id      => ACCESS_KEY,
          :secret_access_key  => ACCESS_PSSWRD
        )
    S3Object.delete("#{self.id}.jpg", BUCKET_APPROVED)
  end
end
