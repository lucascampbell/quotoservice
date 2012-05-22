require 'apn_on_rails'
require File.join(File.dirname(__FILE__),'../config/environment')
class PushJob
  @queue = :push_job

  def self.perform()
    begin
      puts "about to send group notification"
      gr = APN::GroupNotification.first
      APN::App.send_group_notifications(gr)
      puts "sent notification"
      #APN::App.process_devices
    rescue Exception => e
      puts "error #{e.message}"
      raise e
    end
  end
end