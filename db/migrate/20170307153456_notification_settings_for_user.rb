class NotificationSettingsForUser < ActiveRecord::Migration
  def change
    add_column :users, :notification_settings,:json

  end
end
