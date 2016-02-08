class BlueprintsController < ApplicationController
  before_action :set_blueprint, only: [:show, :edit, :update, :destroy]

  # GET /blueprints
  # GET /blueprints.json
  def index
    @blueprints = Blueprint.all
  end

  # GET /blueprints/1
  # GET /blueprints/1.json
  def show
  end

  # GET /blueprints/new
  def new
    @blueprint = Blueprint.new
  end

  # GET /blueprints/1/edit
  def edit
  end

  # POST /blueprints
  # POST /blueprints.json
  def create
    @blueprint = Blueprint.new
    @blueprint.update_attributes(blueprint_params)

    respond_to do |format|
      if @blueprint.save
        format.html { redirect_to @blueprint, notice: 'Blueprint was successfully created.' }
        format.json { render :show, status: :created, location: @blueprint }
      else
        format.html { render :new }
        format.json { render json: @blueprint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /blueprints/1
  # PATCH/PUT /blueprints/1.json
  def update
    respond_to do |format|
      if @blueprint.update(blueprint_params)
        format.html { redirect_to @blueprint, notice: 'Blueprint was successfully updated.' }
        format.json { render :show, status: :ok, location: @blueprint }
      else
        format.html { render :edit }
        format.json { render json: @blueprint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blueprints/1
  # DELETE /blueprints/1.json
  def destroy
    @blueprint.destroy
    respond_to do |format|
      format.html { redirect_to blueprints_url, notice: 'Blueprint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blueprint
      @blueprint = Blueprint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def blueprint_params
      params.require(:blueprint).permit(:name, :body, 
        components_attributes: [ :id, :name, :body, :component_type, :_destroy,
          deployment_rule_attributes: [ :id, :more_attributes ]
        ]
      )
    end
end
