

# Add an initial admin user
unless User.find_by_is_admin(TRUE)
  User.create!({:email => 'admin@thestove.io', :password => 'adminadmin', :password_confirmation => 'adminadmin',  :is_admin => TRUE})
end
