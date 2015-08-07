class RecordsController < ApplicationController
  # def index
  #   @records = Record.paginate(:page => params[:page], :per_page => 50)
  # end

  def import
    Record.import
    redirect_to records_path
  end

  def search
    @records = Record.search(params).paginate(:page => params[:page], :per_page => 50)
  end

  private
    def record_params
      params.require(:record).permit!
    end
end
