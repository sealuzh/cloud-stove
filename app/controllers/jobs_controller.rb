class JobsController < ApplicationController

  def index
    respond_to do |format|
      format.html{
        @jobs ||= Delayed::Web::Job.all
      }

      format.json{
        @jobs = JobWrapper.all
        render json: @jobs, status: :ok
      }
    end
  end

  def show
    respond_to do |format|
      format.html {
        @job ||= Delayed::Web::Job.find params[:id]
      }

      format.json {
        @job = JobWrapper.find_by_uuid(params[:id])
        if @job.nil?
          render json:'There is no job with the given ID!', status: :not_found
        else
          render json: @job, status: :ok
        end
      }
    end

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