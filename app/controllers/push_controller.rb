class PushController < ApplicationController
  API_TOKEN = '41b34acb018529a92603a5b28aadc8ca7dd369d13b3be272e6'
  URL       = 'https://secure.pushhero.com/api/v1'
  KINGS_DAY = Time.parse("09-10-1979")
  
  def index
    @tab = 'push'
    @notifications = APN::GroupNotification.find(:all,:order=>"id DESC",:conditions=>["sent_at IS NULL"])
    resp = RestClient.get(URL + '/scheduled_notifications/goverse',{:AUTHORIZATION => API_TOKEN})
    @remote_notifications = JSON.parse(resp)
    puts @remote_notifications
  end
  
  def send_remote_push(params)
    begin
      #s_time = time_set
      params_apn = set_apn_params(params)
      params_apn[:notification].merge!(:date=>KINGS_DAY)
      params_c2dm = set_c2dm_params(params)
      params_c2dm[:notification].merge!(:date=>KINGS_DAY)
      RestClient.post URL + '/notification', params_apn.to_json, {:AUTHORIZATION => API_TOKEN,:content_type => :json, :accept => :json}
      RestClient.post URL + '/notification', params_c2dm.to_json, {:AUTHORIZATION => API_TOKEN,:content_type => :json, :accept => :json}
      msg = "Successfully pushed"
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
        c2dm.device_id = 5 
        c2dm.save
        
        msg = "Successfully pushed"
    rescue Exception => e
        puts "#{e.message} \n #{e.backtrace}"
        msg = e.message.size > 200 ? e.message[0..200] : e.message
        msg = "Failed to push: #{msg}"
    end
    #send_remote_push(params)
    #render :json => {:text =>msg}
    redirect_to :index
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
  
  #def time_set
    # resp = RestClient.get(URL + '/scheduled_notifications?app_name=goverse',{:AUTHORIZATION => API_TOKEN,:content_type => :json, :accept => :json})
    #     notifications = JSON.parse(resp)
    #     days   = notifications.size
    #     mytime = days.from_now
    #     year   = mytime.year
    #     month  = mytime.month
    #     day    = mytime.day
    #     hour   = 12
    #     Time.new(year,month,day,hour)
  #end
end
