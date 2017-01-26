begin
# Add an initial admin user
admin_password = 'admin'
User.create!({
  email: 'admin@thestove.io',
  password: admin_password,
  password_confirmation: admin_password,
  is_admin: true
})
end
