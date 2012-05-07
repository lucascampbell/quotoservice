class ApiController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :authenticate_token
  
  def get_quotes
    return not_found_action unless params[:id]
    #start = Time.now
    #puts "start #{start}"
    quotes = Quote.where("id > ? AND active = ?",params[:id],true).order("id ASC")
    #end_t =Time.now
    #puts "end #{end_t}"
    #puts "diff #{end_t - start}"
    q_json = quotes.blank? ? {:q =>[],:id => "uptodate"}.to_json : {:q => quotes, :id => quotes.last.id}.to_json
    render :json => q_json
  end
  
  def set_quote
    #quote,citation,book fields passed
    return bad_data_error_action if params['quote'].blank? or params['id'].blank? or params['id_last'].blank?
    quote = Quote.new
    quote.quote = params['quote']
    quote.citation = params['citation']
    quote.book = params['book']
    quote.check_id(params['id'])
    
    # quote should only fail if quote already exists if so return updates
    if quote.save
      render :json => {:q => 'noupdates', :id => quote.id}.to_json
    else
      if quote.errors['quote'].first == 'has already been taken'
        quotes = Quote.where("id > ? AND active = ?",params['id_last'],true).order("id ASC")
        q_json = quotes.blank? ? {:q =>[],:id => "uptodate"}.to_json : {:q => quotes, :id => quotes.last.id}.to_json
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
