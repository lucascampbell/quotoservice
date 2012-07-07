require 'apn_on_rails'
require File.join(File.dirname(__FILE__),'../config/environment')
class PushJob
  @queue = :push_job

  def self.perform()
    begin
      #send for iphone
      app   = APN::App.first
      count = app.devices.count
      puts "apn device count is #{loops}"
      loops = count/90
      remaining = count % 90
      
      loop_arr = []
      loops.times do |index|
        loop_arr << 90 * (index + 1)
      end
      loop_arr << remaining + loop_arr.last if remaining > 0
      puts "loop_ar is #{loop_arr}"
      
      loop_arr.each do |limit|
        app.send_daily_apple_group_notification(limit)
      end
      #send for android
      C2dm::Notification.send_daily_notification
      app.process_devices
    rescue Exception => e
      puts "error #{e.message}"
      raise e
    end
  end
end