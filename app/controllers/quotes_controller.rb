class QuotesController < ApplicationController
  
  def index
    @tab = 'home'
    @quotes = Quote.all
  end
  
  def new
    @tab = 'new'
    @quote = Quote.new
  end
  
  def create
    @quote    = Quote.new(params[:quote])
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
  end
  
  def update
    @quote = Quote.find_by_id(params[:id])
    if @quote.update_attributes(params[:quote])
      flash[:notice] = "Quote updated successfully"
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end
  
  def show
    
  end
  
  def delete
    
  end
  
  def activate
    @quote = Quote.find_by_id(params[:id])
    @quote.active = true
    @quote.save
    flash[:notice] = "Quote activated successfully"
    redirect_to :action => :index
  end
end
