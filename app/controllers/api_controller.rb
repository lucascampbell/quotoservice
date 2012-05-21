class ApiController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :authenticate_token
  
  def get_quotes
    return not_found_action unless params[:id]
    
    quotes = Quote.where("id > ? AND active = ?",params[:id],true).order("id ASC")
    if quotes.blank? 
      q_json = {:q =>"noupdates",:id => nil}
    else
      #loop through quotes and insert tag ids for json resp.  DEPRECATION WARNING is thrown, alternative is to overwrite json method 
      q_formatted = format_quotes(quotes)
      q_json = {:q => q_formatted, :id => quotes.last.id}
    end
    render :json => q_json
  end
  
  def set_quote
    #quote,citation,book fields passed
    return bad_data_error_action if params['quote'].blank? or params['id_last'].blank? or params['citation'].blank? or params['book'].blank?
    quote = Quote.new
    quote.quote = params['quote']
    quote.citation = params['citation']
    quote.book = params['book']
    quote.set_id
    
    # quote should only fail if quote already exists if so return updates
    if quote.save
      render :json => {:q => 'noupdates', :id => quote.id}
    else
      if quote.errors['quote'].first == 'has already been taken'
        quotes = Quote.where("id > ? AND active = ?",params['id_last'],true).order("id ASC")
        q_formatted = format_quotes(quotes)
        q_json = quotes.blank? ? {:q =>"noupdates",:id => nil} : {:q => q_formatted, :id => q_formatted.last.id}
        render :json => q_json
      else
        return bad_data_error_action
      end
    end
  end
  
  def register_device
    puts "params are -- #{params[:id]}"
    return not_found_action unless params[:id]
    begin
      app = APN::App.first
      app = APN::App.create!(:apn_dev_cert => "apple_push_development.pem", :apn_prod_cert => "") unless app
      a = APN::Device.create(:token => params[:id],:app_id => app.id)
      a.errors.count > 0
        resp = "failure"
        gr = Group.find_by_name("Apple")
        gr.devices << a
      else
        resp = "success"
      end
      
      render :json => {:text => a.errors}
    rescue Exception => e
      render :json => {:text => 'failure'}
    end
  end
  
  private
  
  def authenticate_token
    puts "http is  --- #{request.env['HTTP_AUTHORIZATION']}"
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
  
end
