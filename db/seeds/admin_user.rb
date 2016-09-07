# Add an initial admin user
User.create!({
  email: 'admin@thestove.io',
  password: 'seal-stove-admin',
  password_confirmation: 'seal-stove-admin',
  is_admin: true
})
