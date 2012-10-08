class QuotesController < ApplicationController
  
  def index
    @tab = 'home'
    @quotes = Quote.paginate(:page=>params[:page]).order('id DESC')
  end
  
  def new
    @tab = 'new'
    @quote = Quote.new
    @tags   = Tag.all
    @topics = Topic.all
  end
  
  def create
    p,tags,topics = normalize_quote(params)
    puts "quote is #{p[:quote]}"
    p[:quote] = p[:quote]["quote"].gsub(/(\r\n|\n|\r)/,' ')
    
    @quote = Quote.new(p[:quote])
    tags.each do |t_id|
      @quote.tags << Tag.find_by_id(t_id)
    end
    
    topics.each do |tp_id|
       @quote.topics << Topic.find_by_id(tp_id)
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
    p,tags,topics = normalize_quote(params)
    @quote = Quote.find_by_id(p[:id])
    p[:quote] = p[:quote]["quote"].gsub(/(\r\n|\n|\r)/,' ')
    if tags
      @quote.tags = []
      tags.each do |t_id|
        @quote.tags << Tag.find_by_id(t_id)
      end
    end
    
    if topics
      @quote.topics = []
      topics.each do |tp_id|
         @quote.topics << Topic.find_by_id(tp_id)
       end
    end
    
    if @quote.update_attributes(params[:quote])
      flash[:notice] = "Quote updated successfully"
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end
  
  def destroy
    Quote.find(params[:id]).destroy
    qc = QuoteCreate.find_by_quote_id(params[:id])
    qc.destroy if qc
    flash[:notice] = "Quote deleted successfully"
    redirect_to :action => :index
  end
  
  def activate
    @quote = Quote.find_by_id(params[:id])
    @quote.active = true
    @quote.save
    @quote.log_create
    flash[:notice] = "Quote activated successfully"
    redirect_to :action => :index
  end
  
  def deactivate
    @quote = Quote.find_by_id(params[:id])
    @quote.active = false
    @quote.save
    @quote.log_deactivate
    flash[:notice] = "Quote deactivated successfully"
    redirect_to :action => :index
  end
  
  private

  def normalize_quote(p)
    tags = p["quote"]["tags"] ? p["quote"]["tags"].dup : [] 
    tags = tags.delete_if{|t|t == ""}
    p["quote"].delete("tags")
    
    topics = p["quote"]["topics"] ? p["quote"]["topics"].dup : [] 
    topics = topics.delete_if{|t|t == ""}
    p["quote"].delete("topics")
    
    return p,tags,topics
  end
    
end
