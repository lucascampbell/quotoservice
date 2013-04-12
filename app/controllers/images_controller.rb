class ImagesController < ApplicationController
  before_filter :set_tab
  
  def index
    @images = Image.paginate(:page=>params[:page]).order('approved_at DESC, id DESC')
  end
  
  def new
    @image = 'new'
    @image = Image.new
  end
  
  def create
    file = params[:image][:attachment]
    puts "file is #{file.inspect}"
    p,tags = normalize_params(params[:image])
    
    @image = Image.new(p)
    @image.set_id
    
    if tags
      @image.tags = []
      tags.each do |t_id|
        @image.tags << Tag.find_by_id(t_id)
      end
    end
    
    if @image.save
      res = @image.upload_to_s3(file)
      if res
        @image.destroy
        flash[:alert] = res
        render :action => :new
      else
        @tab = 'new'
        flash[:notice] = "Image saved successfully"
        redirect_to :action => :index
      end
    else
      render :action => :new
    end
  end
  
  def edit
    @image = Image.find_by_id(params[:id])
  end
  
  def update
    @image = Image.find_by_id(params[:id])
    if @image
      p,tags = normalize_params(params[:image])
      if tags
        @image.tags = []
        tags.each do |t_id|
          @image.tags << Tag.find_by_id(t_id)
        end
      end
      @image.update_attributes(p)
      flash[:notice] = "Image updated successfully"
      redirect_to :action => :index
    else
      flash[:alert] = "Image not found."
      render :action => :edit
    end
  end
  
  def destroy
    Image.find(params[:id]).destroy
    flash[:notice] = "Image deleted successfully"
    redirect_to :action => :index
  end
  
  def activate
    begin
      image = Image.find(params[:id])
      image.activate_s3_image
    rescue Exception=>e
      flash[:alert] = e.message
    end
    flash[:notice] = "Successfully activated image."
    redirect_to :action=> :index
  end
  
  def deactivate
    begin
      image = Image.find(params[:id])
      image.deactivate_s3_image
    rescue Exception=>e
      flash[:alert] = e.message
    end
    flash[:notice] = "Successfully deactivated image."
    redirect_to :action=> :index
  end
  
  private 
  
  def set_tab
    @tab = 'image'
  end
  
  def normalize_params(p)
    p.delete("attachment")
    tags = p["tags"] ? p["tags"].dup : [] 
    tags = tags.delete_if{|t|t == ""}
    p.delete("tags")
    return p,tags
  end
end
