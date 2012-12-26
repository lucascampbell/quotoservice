class TopicsController < ApplicationController
  def index
    @tab = 'topic'
    @topics = Topic.paginate(:page=>params[:page]).order('id DESC')
  end
  
  def new
    @tab = 'new'
    @topic = Topic.new
  end
  
  def create
    @topic    = Topic.new(params[:topic])
    @topic.set_id
    if @topic.save
      flash[:notice] = "Topic saved successfully"
      redirect_to :action => :index
    else
      render :action => :new
    end
  end
  
  def edit
    @topic = Topic.find_by_id(params[:id])
  end
  
  def update
    @topic = Topic.find_by_id(params[:id])
    if @topic.update_attributes(params[:topic])
      flash[:notice] = "Topic updated successfully"
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end
  
  def show
    
  end
  
  def destroy
    Topic.find(params[:id]).delete
    flash[:notice] = "Topic deleted successfully"
    redirect_to :action => :index
  end
end
