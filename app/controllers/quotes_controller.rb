class QuotesController < ApplicationController
  
  def index
    @tab = 'home'
    @quotes = Quote.all(:order=>'id DESC')
  end
  
  def new
    @tab = 'new'
    @quote = Quote.new
    @tags   = Tag.all
    @topics = Topic.all
  end
  
  def create
    tags = params[:quote][:tags] ? params[:quote][:tags].dup : [] 
    tags = tags.delete_if{|t|t == ""}
    params[:quote].delete('tags')
    @quote = Quote.new(params[:quote])
    tags.each do |t_id|
      @quote.tags << Tag.find_by_id(t_id)
    end
    @quote.set_id
    
    if @quote.save
      flash[:notice] = "Quote saved successfully"
      redirect_to :action => :index
    else
      render :action => :new
    end
  end
  
  def edit
    @quote = Quote.find_by_id(params[:id])
    @tags   = Tag.all
    @topics = Topic.all
  end
  
  def update
    tags = params[:quote][:tags] ? params[:quote][:tags].dup : [] 
    tags = tags.delete_if{|t|t == ""}
    params[:quote].delete('tags')
    @quote = Quote.find_by_id(params[:id])
    if tags
      @quote.tags = []
      tags.each do |t_id|
        @quote.tags << Tag.find_by_id(t_id)
      end
    end
    if @quote.update_attributes(params[:quote])
      flash[:notice] = "Quote updated successfully"
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end
  
  def show
    
  end
  
  def destroy
    Quote.find(params[:id]).delete
    flash[:notice] = "Quote deleted successfully"
    redirect_to :action => :index
  end
  
  def activate
    @quote = Quote.find_by_id(params[:id])
    @quote.active = true
    @quote.save
    flash[:notice] = "Quote activated successfully"
    redirect_to :action => :index
  end
end
