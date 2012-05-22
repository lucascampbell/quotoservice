require 'apn_on_rails'
require File.join(File.dirname(__FILE__),'../config/environment')
class PushJob
  @queue = :push_job

  def self.perform()
    begin
      gnoty = APN::GroupNotification.first
      app   = APN::App.first
      app.send_group_notification(gnoty)
      
      #APN::App.process_devices
    rescue Exception => e
      puts "error #{e.message}"
      raise e
    end
  end
end