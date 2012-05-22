# Override your default settings for the Production environment here.
# 
# Example:
#   configatron.file.storage = :s3
 configatron.apn.passphrase  = ''
 configatron.apn.port  = 2195
 configatron.apn.host  = 'gateway.sandbox.push.apple.com'
 configatron.apn.cert = File.join(Rails.root,'config', 'apple_push_development.pem')