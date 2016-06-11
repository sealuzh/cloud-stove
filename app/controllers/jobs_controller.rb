class JobsController < ApplicationController

  def index
    @jobs ||= Delayed::Web::Job.all
  end

  def show
    @job ||= Delayed::Web::Job.find params[:id]
  end

end