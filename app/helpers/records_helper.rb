require 'ipaddr'

module RecordsHelper
  def int_to_ip(int)
    IPAddr.new(int, Socket::AF_INET6).native
  end
end
