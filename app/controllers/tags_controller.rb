class TagsController < ApplicationController
  before_filter :set_tab
  
  def index
    @tags = Tag.paginate(:page=>params[:page]).order('id DESC')
  end
  
  def new
    @tab = 'new'
    @tag = Tag.new
  end
  
  def create
    @tag    = Tag.new(params[:tag])
    @tag.set_id
    if @tag.save
      flash[:notice] = "Topic saved successfully"
      redirect_to :action => :index
    else
      render :action => :new
    end
  end
  
  def edit
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
  
  private 
  
  def set_tab
    @tab = 'tag'
  end
end
