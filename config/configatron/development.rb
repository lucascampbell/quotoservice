# Override your default settings for the Development environment here.
# 
# Example:
#   configatron.file.storage = :local
# development (delivery):
  # configatron.apn.passphrase  = ''
  #  configatron.apn.port  = 2195
  #  configatron.apn.host  = 'gateway.sandbox.push.apple.com'
  configatron.apn.cert = File.join('config', 'apple_push_development.pem')
