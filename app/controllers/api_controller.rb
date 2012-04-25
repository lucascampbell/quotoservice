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
  
  def authenticate_token
    return internal_error_action unless request.env["HTTP_AUTHORIZATION"] == '&3!kZ1Ct:zh7GaM'
  end
  
end
