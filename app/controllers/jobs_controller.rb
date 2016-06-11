class JobsController < ApplicationController

  def index
    @jobs ||= Delayed::Web::Job.all
  end

  def show
    @job ||= Delayed::Web::Job.find params[:id]
  end

  def destroy
    @job ||= Delayed::Web::Job.find params[:id]
    @job.destroy
    redirect_to :back, notice: 'Job was successfully destroyed!'
  end

end