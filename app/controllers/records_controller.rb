class RecordsController < ApplicationController
  # def index
  #   @records = Record.paginate(:page => params[:page], :per_page => 50)
  # end

  def search
    respond_to do |format|
      format.html do
        @records = Record.search(params).paginate(:page => params[:page], :per_page => 50)
      end
      format.json do
        @records = Record.search(params)
        render json: @records
      end
      format.csv do
        @records = Record.search(params).limit(1000)
        render text: @records.to_csv
      end
    end
  end

  def examples
  end

  private
    def record_params
      params.require(:record).permit!
    end
end
