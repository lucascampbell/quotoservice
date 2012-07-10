require 'apn_on_rails'
require File.join(File.dirname(__FILE__),'../config/environment')
class PushJob
  @queue = :push_job

  def self.perform()
    begin
      #send for iphone
      app   = APN::App.first
      app.process_devices
      app.send_daily_apple_group_notification
      #send for android
      #C2dm::Notification.send_daily_notification
      
    rescue Exception => e
      puts "error #{e.message}"
      raise e
    end
  end
end