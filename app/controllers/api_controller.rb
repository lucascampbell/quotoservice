class ApiController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :authenticate_token
  
  def get_quotes
    #render :json => {:q =>"noupdates",:last_id => 1} and return
    return not_found_action unless params[:id] and params[:delete_id] and params[:update_id]
    
    #check for new quotes
    idd = params[:id] == 'id' ? 0 : params[:id]
    
    qc     = QuoteCreate.where("id > ? and active = ?",idd,true).order("id ASC")
    quotes = Quote.where(:id => qc.collect(&:quote_id)) if qc
    if quotes.blank?
      q_json = {:q =>"noupdates",:id => nil}
    else
      #loop through quotes and insert tag ids for json resp.  DEPRECATION WARNING is thrown, alternative is to overwrite json method 
      q_formatted = format_quotes(quotes)
      q_json = {:q => q_formatted, :id => qc.last.id}
    end
    
    #check for deleted quotes
    qd = QuoteDelete.where("id > ?",params[:delete_id]).order("id ASC")
    
    unless qd.blank?
      ids = qd.collect(&:quote_id).join(',')
      delete = {:ids => ids, :last_id => qd.last.id.to_s}
      q_json[:delete] = delete
    end
    
    #check for updated quotes
    # qu = QuoteUpdate.where("id > ?", params[:update_id]).order("id ASC")
    # updates = []
    # qu.each do |quote|
    #   updates << quote.attributes.to_options.delete_if{|key,value| value == 'no' || key == :created_at || key == :updated_at || key == :id}
    # end
    # unless updates.blank?
    #   q_json[:update] = updates
    #   q_json[:update] << {:last_id => qu.last.id}
    # end
    puts "q_json ********* #{q_json}"
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
  
  def set_quote
    #quote,citation,book fields passed
    return bad_data_error_action if params['quote'].blank? or params['citation'].blank? or params['book'].blank?
    quote = Quote.new
    quote.quote = CGI.escapeHTML(params['quote'].gsub("--8",";"))
    quote.citation = params['citation']
    quote.book = params['book']
    quote.set_id
    
    # quote should only fail if quote already exists if so return updates
    if quote.save
      render :json => {:q => 'noupdates', :id => quote.id}
    # else
    #       if quote.errors['quote'].first == 'has already been taken'
    #         quotes = Quote.where("id > ? AND active = ?",params['id_last'],true).order("id ASC")
    #         q_formatted = format_quotes(quotes)
    #         q_json = quotes.blank? ? {:q =>"noupdates",:id => nil} : {:q => q_formatted, :id => q_formatted.last.id}
    #         render :json => q_json
    else
      return bad_data_error_action unless quote.errors['quote'].first == 'has already been taken'
      # if quote.errors['quote'].first == 'has already been taken'
      #         render :json => {:q => 'Quote already exists'}
      #       else
      #         return bad_data_error_action
      #       end
    end
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
  
  private
  
  def authenticate_token
    return internal_error_action unless request.env["HTTP_AUTHORIZATION"] == '&3!kZ1Ct:zh7GaM'
  end
  
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
