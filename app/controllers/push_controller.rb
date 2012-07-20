class PushController < ApplicationController
  
  def index
    @tab = 'push'
    @quotes = Quote.all
    @notifications = APN::GroupNotification.find(:all,:order=>"id DESC",:conditions=>["sent_at IS NULL"])
    @push = Push.new
  end
  
  def send_push
     #THESE CONFIGURATIONS ARE DEFAULT, IF YOU WANT TO CHANGE UNCOMMENT LINES YOU WANT TO CHANGE   
     #configatron.apn.passphrase  = ''   
     #configatron.apn.port = 2195   
     #configatron.apn.host  = 'gateway.sandbox.push.apple.com'   
     #configatron.apn.cert = File.join(Rails.root, 'config', 'apple_push_development.pem')    
     #THE CONFIGURATIONS BELOW ARE FOR PRODUCTION PUSH SERVICES, IF YOU WANT TO CHANGE UNCOMMENT LINES YOU WANT TO CHANGE   
     #configatron.apn.host = 'gateway.push.apple.com'  
     #configatron.apn.cert = File.join(RAILS_ROOT, 'config', 'apple_push_notification_production.pem')
     #app = APN::App.create!(:apn_dev_cert => "apple_push_notification_development.pem", :apn_prod_cert => "")  
     #device = APN::Device.create!(:token =>"460df5a14f8728c5953bca65731f89e447b74025",:app_id => app.id)
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
       #c2dm.data['sound'] = 'welcome.mp3'
       #c2dm.data['vibrate'] = '3'
       #c2dm.data['quote'] = quote.id.to_s
       c2dm.device_id = 5 
       c2dm.save
       
       flash[:notice] = "Successfully pushed"
     rescue Exception => e
       puts "#{e.message} \n #{e.backtrace}"
       msg = e.message.size > 200 ? e.message[0..200] : e.message
       flash[:notice] = "Failed to push: #{msg}"
     end
    redirect_to :controller=>'quotes',:action => 'index'
  end
  
end
