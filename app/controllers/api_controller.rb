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
      quotes.each do |qt|
        ids = qt.tags.collect(&:id)
        qt[:tag_ids] = ids
      end
      q_json = {:q => quotes, :id => quotes.last.id}
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
        q_json = quotes.blank? ? {:q =>"noupdates",:id => nil} : {:q => quotes, :id => quotes.last.id}
        render :json => q_json
      else
        return bad_data_error_action
      end
    end
  end
  
  def authenticate_token
    return internal_error_action unless request.env["HTTP_AUTHORIZATION"] == '&3!kZ1Ct:zh7GaM'
  end
  
end
