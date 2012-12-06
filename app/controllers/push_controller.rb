class PushController < ApplicationController
  API_TOKEN = '41b34acb018529a92603a5b28aadc8ca7dd369d13b3be272e6'
  #b6e04f6b8833a50edd3768f773899f4f3a61dbbdb1c241cc73
  URL       = 'https://secure.pushhero.com/api/v1'
  KINGS_DAY = Time.parse("09-10-1979")
  
  def index
    @tab = 'push'
    @notifications = APN::GroupNotification.where("sent_at IS NULL").order("id DESC")
    resp = RestClient.get(URL + '/daily_notifications/goverse',{:AUTHORIZATION => API_TOKEN})
    @remote_notifications = JSON.parse(resp)
  end
  
  def send_remote_push(params)
    begin
      params_apn = set_apn_params(params)
      params_apn[:notification].merge!(:date=>KINGS_DAY)
      params_c2dm = set_c2dm_params(params)
      params_c2dm[:notification].merge!(:date=>KINGS_DAY)
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
    render :json => {:text =>msg}
  end
  
  def send_push
     begin
       badge = 1
       quote_id = params[:id]
       quote = Quote.find(quote_id.to_i)
       alert = quote.quote.to_s.force_encoding("UTF-8")
       
       #create notification for apple
       notification = APN::GroupNotification.new
       notification.group = APN::Group.find_by_name("APPLE")
       notification.badge = badge   
       notification.sound = 'true'   
       notification.alert = alert
       notification.custom_properties = {:quote => quote.id}  
       notification.save!
       
       #create notification for android
       c2dm = C2dm::Notification.new
       c2dm.collapse_key = (rand * 100000000).to_i.to_s
       c2dm.data = {}
       c2dm.data['alert'] = alert
       c2dm.data['q_id'] = notification.id
       c2dm.device_id = 5 
       c2dm.save
       
       msg = "Successfully pushed"
     rescue Exception => e
       puts "#{e.message} \n #{e.backtrace}"
       msg = e.message.size > 200 ? e.message[0..200] : e.message
       msg = "Failed to push: #{msg}"
     end
    #send_remote_push(params)
    render :json => {:text =>msg}
  end
  
  def delete
    gn = APN::GroupNotification.find_by_id(params[:id])
    id = gn.id
    c2_gn = nil
    C2dm::Notification.where("sent_at is NULL").each do |c2|
       c2_gn = c2 if c2.data['q_id'].to_i == id 
    end
    gn.destroy
    c2_gn.destroy
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
  
  def set_apn_params(params)
   quote = Quote.find(params[:id].to_i)
   alert = quote.quote.to_s.force_encoding("UTF-8")
   {:notification=>{:badge => 1,:custom_properties =>{:quote_id =>params[:id]},:alert=>alert},:group=>'APN_DEV',:app_name=>'goverse'}
  end
  
  def set_c2dm_params(params)
    quote = Quote.find(params[:id].to_i)
    alert = quote.quote.to_s.force_encoding("UTF-8")
    {:notification=>{:data=>{:alert=>alert}},:group=>'C2DM',:app_name=>'goverse'}
  end
  
end
