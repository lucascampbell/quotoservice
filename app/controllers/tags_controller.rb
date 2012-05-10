class TagsController < ApplicationController
  def index
    @tab = 'tag'
    @tags = Tag.all(:order=>'id DESC')
  end
  
  def new
    @tab = 'new'
    @tag = Tag.new
  end
  
  def create
    @tags    = Tag.new(params[:tag])
    @tags.set_id
    if @tags.save
      flash[:notice] = "Topic saved successfully"
      redirect_to :action => :index
    else
      render :action => :new
    end
  end
  
  def edit
    puts "params #{params[:id]}"
    @tag = Tag.find_by_id(params[:id])
  end
  
  def update
    @tag = Tag.find_by_id(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = "Tag updated successfully"
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end
  
  def show
    
  end
  
  def destroy
    Tag.find(params[:id]).delete
    flash[:notice] = "Tag deleted successfully"
    redirect_to :action => :index
  end
end
