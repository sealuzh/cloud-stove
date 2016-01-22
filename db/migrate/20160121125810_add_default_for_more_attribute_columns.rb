class AddDefaultForMoreAttributeColumns < ActiveRecord::Migration
  def change
    ## blueprints
    change_column_null :blueprints, :more_attributes, false
    change_column_default :blueprints, :more_attributes, '{}'

    ## components
    change_column_null :components, :more_attributes, false
    change_column_default :components, :more_attributes, '{}'

    ## application_deployment_recommendations
    change_column_null :application_deployment_recommendations, :more_attributes, false
    change_column_default :application_deployment_recommendations, :more_attributes, '{}'

    ## cloud_applications
    change_column_null :cloud_applications, :more_attributes, false
    change_column_default :cloud_applications, :more_attributes, '{}'

    ## providers
    change_column_null :providers, :more_attributes, false
    change_column_default :providers, :more_attributes, '{}'

    ## resources
    change_column_null :resources, :more_attributes, false
    change_column_default :resources, :more_attributes, '{}'

    ## slos
    change_column_null :slos, :more_attributes, false
    change_column_default :slos, :more_attributes, '{}'
  end
end
