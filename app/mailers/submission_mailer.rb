class SubmissionMailer < ActionMailer::Base
  default from: "app@goverse.org"
  
  def image_submission(email)
    mail(:to=>email,:subject=>'GoVerse Contribution',:date=> Time.now,:content_type=>"text/html")
  end
end
