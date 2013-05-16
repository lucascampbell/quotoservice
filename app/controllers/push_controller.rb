class PushController < ApplicationController
  API_TOKEN = 'b6e04f6b8833a50edd3768f773899f4f3a61dbbdb1c241cc73'
  URL       = 'https://secure.pushhero.com/api/v1'
  APPNAME   = 'goverse'
  skip_before_filter :authenticate_user!, :only=>[:index,:edit_priority]
  
  def index
    @tab = 'push'
    #@notifications = APN::GroupNotification.where("sent_at IS NULL").order("id DESC")
    resp = RestClient.get(URL + "/daily_notifications/#{APPNAME}",{:AUTHORIZATION => API_TOKEN})
    puts JSON.parse(resp)
    @remote_notifications = JSON.parse(resp)
  end
  
  def send_remote_push
    begin
      resp       = RestClient.get URL + "/daily_notifications_count/#{APPNAME}",{:AUTHORIZATION => API_TOKEN}
      next_one   = resp.strip.to_i + 1
      unid1 = SecureRandom.uuid.gsub("-","")
      unid2 = SecureRandom.uuid.gsub("-","")
      params_apn = set_apn_params(params,next_one)
      params_apn[:notification].merge!(:unid=>unid)
      params_c2dm = set_c2dm_params(params,next_one)
      params_c2dm[:notification].merge!(:unid=>unid2)
      resp1 = RestClient.post URL + '/notification', params_apn.to_json, {:AUTHORIZATION => API_TOKEN,:content_type => :json, :accept => :json}
      resp2 = RestClient.post URL + '/notification', params_c2dm.to_json, {:AUTHORIZATION => API_TOKEN,:content_type => :json, :accept => :json}
      r1 = JSON.parse(resp1)
      r2 = JSON.parse(resp2)
      
      msg = "#{r1['text']} - #{r2['text']}"
    rescue Exception => e
      puts "error #{e.message}"
      msg = e.message.size > 200 ? e.message[0..200] : e.message
      msg = "Failed to push: #{msg} \n #{e.backtrace}"
    end
    render :json => {:text => msg}
  end
  
  def edit_priority
    resp = RestClient.get URL + "/edit_priority/#{params[:klss]}/#{params[:priority]}/#{APPNAME}/#{params[:id]}", {:AUTHORIZATION => API_TOKEN}
    render :json => resp
  end
  
  #deprecated with old app
  # def send_push
  #    begin
  #      badge = 1
  #      quote_id = params[:id]
  #      quote = Quote.find(quote_id.to_i)
  #      alert = quote.quote_push.to_s.force_encoding("UTF-8")
  #      
  #      #create notification for apple
  #      notification = APN::GroupNotification.new
  #      notification.group = APN::Group.find_by_name("APPLE")
  #      notification.badge = badge
  #      notification.sound = 'true'
  #      notification.alert = alert
  #      notification.custom_properties = {:quote => quote.id}
  #      notification.save!
  #      
  #      msg = "Successfully pushed"
  #    rescue Exception => e
  #      puts "#{e.message} \n #{e.backtrace}"
  #      msg = e.message.size > 200 ? e.message[0..200] : e.message
  #      msg = "Failed to push: #{msg}"
  #    end
  #   send_remote_push(params)
  #   #render :json => {:text =>msg}
  # end
  
  def delete
    gn = APN::GroupNotification.find_by_id(params[:id])
    id = gn.id
    c2_gn = nil
    C2dm::Notification.where("sent_at is NULL").each do |c2|
       c2_gn = c2 if c2.data['q_id'].to_i == id 
    end
    gn.destroy
    c2_gn.destroy if c2_gn
    redirect_to :action=>'index'
  end
  
  def delete_remote
    id   = params[:id]
    name = params[:name]
    resp = RestClient.delete(URL + "/notification/#{id}/#{name}",{:AUTHORIZATION => API_TOKEN})
    r = JSON.parse(resp)
    flash[:notice] = r['text']
    redirect_to :action=>'index'
  end
  
  private
  
  def set_apn_params(params,next_one)
    quote = Quote.find(params[:id].to_i)
    alert = quote.quote_push.to_s.force_encoding("UTF-8")
    priority = next_one
    queues = 'Daily 8:00am PST,Daily 8:00am EST,Daily 8:00am CST'
    sub_groups = "daily_pst,daily_est,daily_cst"
    {:notification=>{:badge => 1,:custom_properties =>{:id =>params[:id]},:alert=>alert,:priority=>next_one},:group=>'APN_PROD',:app_name=>APPNAME,:queues=>queues,:sub_groups=>sub_groups}
  end
  
  def set_c2dm_params(params,next_one)
    quote = Quote.find(params[:id].to_i)
    alert = quote.quote_push.to_s.force_encoding("UTF-8")
    queues = 'Daily 8:00am PST,Daily 8:00am EST,Daily 8:00am CST'
    sub_groups = "daily_pst,daily_est,daily_cst"
    {:notification=>{:data=>{:alert=>alert},:priority=>next_one},:group=>'C2DM',:app_name=>APPNAME,:queues=>queues,:sub_groups=>sub_groups}
  end
  
end
