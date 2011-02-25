require 'machinist/active_record'

# Add your blueprints here.
#
# e.g.
#   Post.blueprint do
#     title { "Post #{sn}" }
#     body  { "Lorem ipsum..." }
#   end

User.blueprint do
  name { "User #{sn}" }
  email { "user#{sn}@example.com" }
  password { "password" }
  role { "admin" }
end

Account.blueprint do
  #users(1)
end