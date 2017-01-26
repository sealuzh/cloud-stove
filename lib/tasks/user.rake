namespace :user do
  desc 'Update the password of the admin user (default: email `admin@thestove.io` with password `admin`).
        Usage: `rake user:update_admin[new_admin_password]`'
  task :update_admin, [:password] => [:environment]  do |task, args|
    update_admin_password(args[:password])
  end

  def update_admin_password(new_password)
    admin = User.stove_admin
    same_password = admin.valid_password?(new_password)
    admin.update!(password: new_password, password_confirmation: new_password) unless same_password
  end
end
