# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_OnlineChecklistsApp_session',
  :secret      => '2834fd6bd2978a74980c56947999a56e1ddc2c4867872af3c43301513d7fe533b2b2e522907d6825d0a4c513e116586134cc74deb2e9b7b7a70aeb6374c643df'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
