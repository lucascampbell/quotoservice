# Override your default settings for the Development environment here.
# 
# Example:
#   configatron.file.storage = :local
# development (delivery):
  # configatron.apn.passphrase  = ''
  #  configatron.apn.port  = 2195
  #  configatron.apn.host  = 'gateway.sandbox.push.apple.com'
  configatron.apn.cert = File.join('config', 'apple_push_development.pem')
  
  # configatron.c2dm.api_url = 'https://android.apis.google.com/c2dm/send'
  #  configatron.c2dm.username = 'quotesapp.tmc@gmail.com'
  #  configatron.c2dm.password = 'Oples10password'
  #  configatron.c2dm.app_name = 'GoVerse'
