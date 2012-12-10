class QuotesController < ApplicationController
  helper_method :sort_column,:sort_direction
  def index
    @tab = 'home'
    @search_type = 'quote'
    @quotes = Quote.paginate(:page=>params[:page]).order(sort_column + " " + sort_direction)
  end
  
  def search
    @search      = params[:search] || session[:search]
    session[:search] = @search
    
    @search_type = search_type
    @tab         = 'home'
    search_ci    = nil
    search_ci    = @search.downcase if @search
    case @search_type
    when 'tag'
      @quotes = Quote.includes(:tags).select("quotes.id").where("lower(tags.name) like ?","%#{search_ci}%").paginate(:page=>params[:page]).order(sort_column + " " + sort_direction)
    when 'topic'
      @quotes = Quote.includes(:topics).select("quotes.id").where("lower(topics.name) like ?","%#{search_ci}%").paginate(:page=>params[:page]).order(sort_column + " " + sort_direction)
    when 'duplicate'
      #@quotes = Quote
    else
      @quotes = Quote.where("lower(#{search_type}) LIKE ?","%#{search_ci}%").paginate(:page=>params[:page]).order(sort_column + " " + sort_direction)
    end
    render :action => :index
  end
  
  def new
    @tab = 'new'
    @quote = Quote.new
    @tags   = Tag.all
    @topics = Topic.all
  end
  
  def create
    p,tags,topics = normalize_quote(params)
    
    @quote = Quote.new(p[:quote])
    @quote.quote = @quote.quote.gsub(/(\r\n|\n|\r)/,' ')
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
    session[:return_to] = request.referer
  end
  
  def update
    p,tags,topics = normalize_quote(params)
    @quote = Quote.find_by_id(p[:id])
    @quote.quote = @quote.quote.gsub(/(\r\n|\n|\r)/,' ')
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
      #redirect_to :action => :index
      redirect_to session.delete(:return_to)
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
  
  def sort_column
    Quote.column_names.include?(params[:sort]) ? params[:sort] : 'quotes.id'
  end
  
  def sort_direction
    ['asc','desc'].include?(params[:direction]) ? params[:direction] : 'asc'
  end
  
  def search_type
    ['quote','author','book','citation','topic','tag','duplicate'].include?(params[:search_type]) ? params[:search_type] : 'quote'
  end
    
end
