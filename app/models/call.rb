class Call < ActiveRecord::Base
  belongs_to :sip_ip, counter_cache: true, dependent: :destroy
end