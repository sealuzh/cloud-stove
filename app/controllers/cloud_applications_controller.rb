class CloudApplicationsController < ApplicationController
  before_action :set_cloud_application, only: [ :show, :edit, :update, :destroy, :recommendations ]
  before_action :fetch_blueprints, only: [ :new, :edit, :update ]

  # GET /cloud_applications
  # GET /cloud_applications.json
  def index
    @cloud_applications = CloudApplication.page(params[:page])
  end

  # GET /cloud_applications/1
  # GET /cloud_applications/1.json
  def show
  end

  # GET /cloud_applications/new
  def new
    @cloud_application = CloudApplication.new
  end

  # GET /cloud_applications/1/edit
  def edit
  end

  # POST /cloud_applications
  # POST /cloud_applications.json
  def create
    @cloud_application = CloudApplication.new(cloud_application_params)

    respond_to do |format|
      if @cloud_application.save
        format.html { redirect_to @cloud_application, notice: 'Cloud application was successfully created.' }
        format.json { render :show, status: :created, location: @cloud_application }
      else
        @blueprints = Blueprint.all
        format.html { render :new }
        format.json { render json: @cloud_application.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cloud_applications/1
  # PATCH/PUT /cloud_applications/1.json
  def update
    respond_to do |format|
      if @cloud_application.update(cloud_application_params)
        format.html { redirect_to @cloud_application, notice: 'Cloud application was successfully updated.' }
        format.json { render :show, status: :ok, location: @cloud_application }
      else
        @blueprints = Blueprint.all
        format.html { render :edit }
        format.json { render json: @cloud_application.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cloud_applications/1
  # DELETE /cloud_applications/1.json
  def destroy
    @cloud_application.destroy
    respond_to do |format|
      format.html { redirect_to cloud_applications_url, notice: 'Cloud application was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /cloud_applications/:id/recommendations
  def recommendations
    # TODO: Move generating deployment recommendations to background job
    @cloud_application.concrete_components.each do |component|
      component.slo_sets.each do |slo_set|
        slo_set.transaction do
          # Remove existing deployment recommendations before generating new ones
          slo_set.deployment_recommendations.delete_all
          DeploymentRecommendation.compute_recommendation(slo_set)
        end
      end
    end
    redirect_to @cloud_application
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cloud_application
      @cloud_application = CloudApplication.find(params[:id])
    end
    
    def fetch_blueprints
      @blueprints = Blueprint.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cloud_application_params
      params.require(:cloud_application).permit(:name, :body, :blueprint_id,
        concrete_components_attributes: [:id, :name, :body, :component_id, :_destroy, slo_sets_attributes: [:id, :more_attributes, :_destroy]]
      )
    end
end
