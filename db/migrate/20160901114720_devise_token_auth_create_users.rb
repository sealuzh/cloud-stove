class DeviseTokenAuthCreateUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string, :null => false, :default => "email"
    add_column :users, :uid, :string, :null => false, :default => ""
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    add_column :users, :name, :string
    add_column :users, :nickname, :string
    add_column :users, :image, :string
    add_column :users, :tokens, :text

    add_index :users, [:uid, :provider],     :unique => true
    add_index :users, :confirmation_token,   :unique => true
  end
  #
  #   create_table(:users) do |t|
  #     ## Required
  # #    t.string :provider, :null => false, :default => "email"
  # #    t.string :uid, :null => false, :default => ""
  #
  #     ## Database authenticatable
  # #    t.string :encrypted_password, :null => false, :default => ""
  #
  #     ## Recoverable
  # #    t.string   :reset_password_token
  # #    t.datetime :reset_password_sent_at
  #
  #     ## Rememberable
  # #    t.datetime :remember_created_at
  #
  #     ## Trackable
  # #    t.integer  :sign_in_count, :default => 0, :null => false
  # #    t.datetime :current_sign_in_at
  # #    t.datetime :last_sign_in_at
  # #    t.string   :current_sign_in_ip
  # #    t.string   :last_sign_in_ip
  #
  #     ## Confirmable
  # #    t.string   :confirmation_token
  # #    t.datetime :confirmed_at
  # #    t.datetime :confirmation_sent_at
  # #    t.string   :unconfirmed_email # Only if using reconfirmable
  #
  #     ## Lockable
  #     # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
  #     # t.string   :unlock_token # Only if unlock strategy is :email or :both
  #     # t.datetime :locked_at
  #
  #     ## User Info
  #     t.string :name
  #     t.string :nickname
  #     t.string :image
  #     t.string :email
  #
  #     ## Tokens
  #     t.text :tokens
  #
  #     t.timestamps
  #   end
  #
  #   add_index :users, :email
  #   add_index :users, [:uid, :provider],     :unique => true
  #   add_index :users, :reset_password_token, :unique => true
  #   # add_index :users, :confirmation_token,   :unique => true
  #   # add_index :users, :unlock_token,         :unique => true
  # end
end
