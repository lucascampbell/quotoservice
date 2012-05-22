
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
       badge = params[:push][:badge] || 5
       alert = params[:push][:alert] || "Daily Quote"
       quote_id = params[:push][:quote_id] || 1
       quote = Quote.find(quote_id.to_i)
       
       notification = APN::GroupNotification.new   
       notification.group = APN::Group.find_by_name("Apple")
       notification.badge = badge   
       notification.sound = 'true'   
       notification.alert = alert
       notification.custom_properties = {:quote => quote.id}  
       notification.save!
       #APN::App.send_group_notifications
       flash[:notice] = "Successfully pushed"
       #Resque.enqueue(PushJob)
     rescue Exception => e
       puts "#{e.message} \n #{e.backtrace}"
       msg = e.message.size > 200 ? e.message[0..200] : e.message
       flash[:notice] = "Failed to push: #{msg}"
     end
    redirect_to :action => 'index'
  end
  
end