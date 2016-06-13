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

  def run
    @job ||= Delayed::Web::Job.find params[:job_id]
    if @job.can_queue?
      @job.queue!
      redirect_to jobs_path, notice: 'Job has been queued for running.'
    else
      redirect_to jobs_path, notice: 'Job could not be queued.'
    end
  end

end