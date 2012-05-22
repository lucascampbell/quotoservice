require 'apn_on_rails'
class PushJob
  @queue = :push_job

  def self.perform()
    begin
      puts "about to send group notification"
      APN::App.send_group_notifications
      puts "sent notification"
      #APN::App.process_devices
    rescue Exception => e
      puts "error #{e.message}"
      raise e
    end
  end
end