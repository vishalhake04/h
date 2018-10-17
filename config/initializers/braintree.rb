# Braintree::Configuration.environment = :sandbox
# Braintree::Configuration.logger = Logger.new('log/braintree.log')
# Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID']
# Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC_KEY']
# Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY']
if Rails.env.production?
  Braintree::Configuration.environment = :production
  Braintree::Configuration.merchant_id = 'vr3n2pvkzsmpfm72'
  Braintree::Configuration.public_key = 'mp9gys7g876j27z8'
  Braintree::Configuration.private_key = '87b7455bde390c6fdb4fcc6fc5f16bdb'
else
  Braintree::Configuration.environment = :sandbox
=begin
  Braintree::Configuration.merchant_id = 'w5bxtp2b28dh2xyv'
  Braintree::Configuration.public_key  = 'jbwqj7syy7qk64s5'
  Braintree::Configuration.private_key = 'bd4c67420b83165296b6296da8e3cac5'
=end
  Braintree::Configuration.merchant_id = 's6w85vmhx8f7yy7v'
  Braintree::Configuration.public_key  = 'c3q2wvs2fvn5h2sr'
  Braintree::Configuration.private_key = 'a8662a94671000dbd13709b3817f78ca'

end