# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_jobs_session',
  :secret => '4b92cb861beba0fa9d81a00f7c427cc23acf164fd9abbd2d542ea4f3352c59f830212504902ba2ab6ad082317e244f8b21c6055e541a618ec485e8f5493f2085'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
