class SipIpController < ApplicationController
  def search
    respond_to do |format|
      format.html do
        @calls = Call.search(params).paginate(page: params[:page], per_page: 50)
      end
      format.json do
        @calls = Call.search(params)
        render json: @calls
      end
      format.csv do
        @calls = Call.search(params).limit(1000)
        render text: @calls.to_csv
      end
    end

  end

  def top_source
    @ips = Ip.where(source: true).joins(:calls).group(:id).order('count(*) desc').limit(50)
  end
end
