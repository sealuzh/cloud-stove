# Add an initial admin user
admin_password = 'stove-admin'
User.create!({
  email: 'admin@thestove.io',
  password: admin_password,
  password_confirmation: admin_password,
  is_admin: true
})
