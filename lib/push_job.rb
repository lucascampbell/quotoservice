require 'apn_on_rails'
class PushJob
  @queue = :push_job

  def self.perform()
    begin
      APN::App.send_group_notifications
      APN::App.process_devices
    rescue Exception => e
      puts "error #{e.message}"
    end
  end
end