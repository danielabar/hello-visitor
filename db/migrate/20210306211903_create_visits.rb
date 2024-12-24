# frozen_string_literal: true

class CreateVisits < ActiveRecord::Migration[6.0]
  def change
    create_table :visits do |t|
      t.integer :guest_timezone_offset, null: false # JS: new Date().getTimezoneOffset()
      t.string :user_agent, null: false             # JS: navigator.userAgent
      t.string :url, null: false                    # JS: window.location.href
      t.string :remote_ip
      t.string :referrer                            # JS: document.referrer

      t.timestamps
    end
  end
end
