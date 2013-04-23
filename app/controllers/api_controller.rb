class ApiController < ApplicationController
  skip_before_filter :authenticate_user!
  
  before_filter do |controller|
    controller.send :authenticate_token! unless ['quote_by_id','quotes_by_page','quotes_by_topic_id_name','topic_by_id_name','topics_by_status','topics_by_page','quotes_by_search'].include?(controller.action_name)
  end
  
  def get_quotes
    #render :json => {:q =>"noupdates",:last_id => 1} and return
    return not_found_action unless params[:id] and params[:delete_id] and params[:update_id]
    
    #check for new quotes
    idd = params[:id] == 'id' ? 0 : params[:id]
    
    qc     = QuoteCreate.where("id > ? and active = ? and version = ?",idd,true,1).order("id ASC")
    
    quotes = Quote.where(:id => qc.collect(&:quote_id)) if qc
    if quotes.blank?
      q_json = {:q =>"noupdates",:id => nil}
    else
      #loop through quotes and insert tag ids for json resp.  DEPRECATION WARNING is thrown, alternative is to overwrite json method 
      q_formatted = format_quotes(quotes)
      q_json = {:q => q_formatted, :id => qc.last.id}
    end
    
    #check for deleted quotes
    qd = QuoteDelete.where("id > ? and version = ?",params[:delete_id],1).order("id ASC")
    
    unless qd.blank?
      ids = qd.collect(&:quote_id).join(',')
      delete = {:ids => ids, :last_id => qd.last.id.to_s}
      q_json[:delete] = delete
    end
    
    #check for updated quotes
    qu = QuoteUpdate.where("id > ?", params[:update_id]).order("id ASC")
    
    updates = []
    qu.each do |quote|
      updates << quote.attributes.to_options.delete_if{|key,value| value == 'no' || key == :created_at || key == :updated_at || key == :id}
    end
    unless updates.blank?
      q_json[:update] = updates
      q_json[:update] << {:last_id => qu.last.id}
    end
   
    render :json => q_json
  end
  
  #v2 update 
  def get_updates
    return not_found_action unless validate_params?(params)
    
    json = {:quotes=>{},:tags=>{},:topics=>{}}
    #check for new quotes
    json[:quotes] = Quote.quotes_new(params[:q_create_id])
    
    #check for deleted quotes
    json[:quotes].merge!(Quote.quotes_delete(params[:q_delete_id]))
  
    #check for new tags
    json[:tags] = Tag.tags_new(params[:tag_create_id])
    
    #check for deleted tags
    json[:tags].merge!(Tag.tags_delete(params[:tag_delete_id]))
     
    #check for new topics
    json[:topics] = Topic.topics_new(params[:topic_create_id])
    
    #check for deleted_topics
    json[:topics].merge!(Topic.topics_delete(params[:topic_delete_id]))
    
    render :json => json
  end
  
  def get_image_updates
    return not_found unless params[:i_delete_id] and params[:i_create_id]
    json = {}
    json[:images] = {}
    json[:images] = Image.images_new(params[:i_create_id])
    json[:images].merge!(Image.images_delete(params[:i_delete_id]))
    
    render :json => json
  end
  
  def set_quote
    #quote,citation,book fields passed
    return bad_data_error_action if params['quote'].blank? or params['citation'].blank? or params['book'].blank?
    quote = Quote.new
    if Quote.resembles_base64?(params['quote'])
      quote.quote = Base64.decode64(params['quote'])
    else
      quote.quote = CGI.escapeHTML(params['quote'].gsub("--8",";"))
    end
    quote.citation = params['citation']
    quote.book = params['book']
    
    quote.set_id
    
    # quote should only fail if quote already exists if so return updates
    if quote.save
      render :json => {:q => 'noupdates', :id => quote.id}
    else
      if quote.errors['quote'].first == 'has already been taken'
        render :json => {:q => 'noupdates', :id => quote.id}
      else
        return bad_data_error_action 
      end
    end
  end
  
  def create_image
    return bad_data_error_action unless params[:device_name]
    begin
      Image.create_device_uploaded_image(params)
      msg = 'success'
    rescue Exception=>e
      puts "error #{e.message} \n #{e.backtrace}"
      msg = e.message
    end
    render :json => {:text => msg}
  end
  
  def register_device
    return not_found_action unless params[:id] and params[:platform]
    begin
      platform = params[:platform]
      
      if platform == 'APPLE'
        app = APN::App.first
        a = APN::Device.create(:token => params[:id],:app_id => app.id)
      else
        a = C2dm::Device.create(:registration_id => params[:id])
      end
      
      if a.errors.count > 0
        resp = a.errors[:token].first =~ /has already been taken/ ? "success" : "failure" if platform == 'APPLE'
        resp = a.errors[:registration_id].first =~ /has already been taken/ ? "success" : "failure" unless platform == 'APPLE'
        #touch last registered at date so android doesn't remove device
        a.save if platform == "ANDROID" and resp == "success"
      else
        resp = "success"
        gr = APN::Group.find_by_name(platform.strip)
        if platform == "APPLE"
          gr.devices << a 
        else
          gr.c2_devices << a
        end
      end
      
      render :json => {:text => resp}
    rescue Exception => e
      puts "excep- #{e.message}"
      render :json => {:text => 'failure'}
    end
  end
  
  def snapshot
    json = []
    json = Quote.quotes_all
    json.merge!(Tag.tags_all)
    json.merge!(Topic.topics_all)
    render :json => json
  end
  
  def add_to_daily_verse
    id = params[:id]
    if id
      t = Topic.find_by_name("Daily Verse")
      max = t.quotes.maximum(:order_index)
      q = Quote.find(id)
      q.update_attributes(:order_index=>max+1)
      t.quotes << q
      t.save
      q.save
      msg = 'success'
    else
      msg = 'quote_id not found'
    end
    render :json => {:text => msg}
  end
  
  # START OF WEBSITE API ACTIONS POSSIBLY TO BE ABSTRACTED
  
  def quotes_by_page
    @quotes = Quote.paginate(:page=>params[:page]).order("id DESC").select("id,quote,citation,book,translation,rating,author,order_index").where(:active=>true)
    render :json => @quotes.to_json, :callback=>params[:callback]
  end
  
  def quote_by_id
    @quote = Quote.select("id,quote,citation,book,translation,rating,author,order_index").where(:id=>params[:id])
    render :json => @quote.to_json, :callback=>params[:callback]
  end
  
  def quotes_by_search
    search = params[:search]
    search_ci    = search.downcase if search
    @quotes = Quote.includes(:tags,:topics).where("lower(quote) LIKE ?","%#{search_ci}%").paginate(:page=>params[:page]).order("topics.name DESC,tags.name")
    render :json => @quotes.to_json, :callback=>params[:callback]
  end
  
  def quotes_by_topic_id_name
    id   = params[:id]
    name = params[:name] 
    @quotes = Quote.paginate(:page=>params[:page]).includes(:topics).select("id,quote,citation,book,translation,rating,author,order_index").where("lower(topics.name) = ? and quotes.active = ? ",name.downcase,true).order("quotes.id DESC") if name
    @quotes = Quote.paginate(:page=>params[:page]).includes(:topics).select("id,quote,citation,book,translation,rating,author,order_index").where("topics.id = ? and quotes.active = ? ",id,true).order("quotes.id DESC") if id
    
    render :json => @quotes.to_json, :callback=>params[:callback]
  end
  
  def topic_by_id_name
    id   = params[:id]
    name = params[:name]
    @topic = Topic.select("id,name,status,order_index").where("id = ?",id).order("id DESC") if id
    @topic = Topic.select("id,name,status,order_index").where("lower(name) = ?",name.downcase).order("id DESC") if name
    
    render :json => @topic.to_json, :callback=>params[:callback]
  end
  
  def topics_by_status
    status = params[:status] 
    @topics = Topic.paginate(:page=>params[:page]).select("id,name,status,order_index").where("status = ?",status).order("id DESC") if status
    
    render :json => @topics.to_json, :callback=>params[:callback]
  end
  
  def topics_by_page
    @topics = Topic.paginate(:page=>params[:page]).select("id,name,status,order_index").order("id DESC")
    
    render :json => @topics.to_json, :callback=>params[:callback]
  end
  
  def random_standard_quotes
    #no hidden or featured topics
  end
  
  private
  
  def format_quotes(quotes)
    quotes.each do |qt|
      t_ids  = qt.tags.collect(&:id)
      tp_ids = qt.topics.collect(&:id)
      qt[:tag_ids] = t_ids
      qt[:topic_ids] = tp_ids
    end
    quotes
  end
  
  def validate_params?(params)
    params[:q_delete_id] and 
    params[:q_create_id] and 
    params[:tag_create_id] and 
    params[:tag_delete_id] and 
    params[:topic_create_id] and 
    params[:topic_delete_id]
  end
end
