require 'apn_on_rails'
class PushJob
  @queue = :push_job

  def self.perform()
    begin
      APN::App.send_group_notifications
    rescue Exception => e
      puts "error #{e.message}"
    end
  end
end