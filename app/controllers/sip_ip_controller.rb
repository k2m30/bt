class SipIpController < ApplicationController
  def search
    @calls = Call.search(params).paginate(page: params[:page], per_page: 50)
  end

  def top_source
    @ips = Ip.where(source: true).joins(:calls).group(:id).order('count(*) desc').limit(50)
  end
end
