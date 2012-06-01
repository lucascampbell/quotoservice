# Override your default settings for the Production environment here.
# 
# Example:
#   configatron.file.storage = :s3
 configatron.apn.passphrase  = ''
 configatron.apn.port  = 2195
 configatron.apn.host  = 'gateway.sandbox.push.apple.com'
 configatron.apn.cert = File.join(Rails.root,'config', 'apple_push_development.pem')
 
 
 configatron.c2dm.api_url = 'https://android.apis.google.com/c2dm/send'
 configatron.c2dm.username = 'lkecamp1@gmail.com'
 configatron.c2dm.password = 'hrtmember'
 configatron.c2dm.app_name = 'goverse'