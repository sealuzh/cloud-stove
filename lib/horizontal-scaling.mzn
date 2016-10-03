% Number of (atomic) ingredients, i.e., components to be deployed
int: num_ingredients;
set of int: Ingredients = 1..num_ingredients;

% Total number of resources available for deployment
int: num_resources;
set of int: Resources = 1..num_resources;

% [1..num_resources] or [Resources] arrays are ordered and represent 
% all resources available for deployment across all providers, across
% all regions (hopefully this does not get too big to solve)

% Resource IDs
array[Resources] of int: resources;

% Regions as region hashes derived from provider name and region name
array[Resources] of int: regions;

% Resource prices per hour (maybe month?) in mUSD
array[Resources] of int: costs;

% RAM per resource
array[Resources] of int: ram;

% CPU cores/usage per resource
% FIXME: ideally should be something we can fairly compare across providers
array[Resources] of int: cpu;

% Network transfer costs between resources
array[Resources, Resources] of int: transfer_costs;

% Component dependencies modeled as traffic flow between ingredients
array[Ingredients, Ingredients] of int: inter_ingredient_traffic;

% Component RAM requirements
array[Ingredients] of int: min_ram;

% Component CPU requirements
array[Ingredients] of int: min_cpus;

% Region constraints for each ingredient
array[Ingredients, Resources] of bool: preferred_regions;

%
% Decision variables
%

% Component assignment
int: max_num_assignments = 9999;
array[Ingredients, Resources] of var 0..max_num_assignments: assignments;

int: max_costs = 999 * max(costs);
array[Ingredients] of var 1..max_costs: assignment_costs;

% Total Deployment Cost
var int: total_cost;

% Minimize total cost
solve %:: int_search(assignment_costs, first_fail, indomain_min, complete)
  minimize total_cost;

%
% Constraints
%

constraint forall(i in Ingredients)(assignment_costs[i] == sum(r in Resources)(assignments[i,r] * costs[r]));

% Calculate total cost
constraint total_cost = 
  % Resource cost
  sum(i in Ingredients, r in Resources)(
    assignments[i,r] * costs[r]
%   ) + 
  % Communication costs 
  % (for now, inter-ingredient traffic occurs once per resource per ingredient, 
  % i.e. if there are multiple different resources per ingredient, each will get traffic 
  % assigned once)
  % TODO: properly split traffic between ingredients
%   sum(i, j in Ingredients, ri, rj in Resources where inter_ingredient_traffic[i,j] > 0 /\ transfer_costs[ri,rj] > 0 /\ assignments[i,ri] > 0 /\ assignments[j,rj] > 0)(
%     inter_ingredient_traffic[i,j] * transfer_costs[ri,rj]
  % NOTE: transfer costs are currently the major factor in model execution time.
  % disabling transfer costs calculations _significantly_ speeds up the solver
  % (for a simple recommendation: from ~8s to ~100ms)
  );

% Chosen resources must be in the preferred region
% constraint forall(i in Ingredients, r in Resources)(preferred_regions[i, r] == true \/ assignments[i,r] == 0);
constraint forall(i in Ingredients, r in Resources where preferred_regions[i,r] == false)(assignments[i,r] == 0);

% Chosen resources must have enough RAM
constraint forall(i in Ingredients)(sum(r in Resources)(assignments[i,r] * ram[r]) >= min_ram[i]);

% Chosen resources must have enough CPU cores
constraint forall(i in Ingredients)(sum(r in Resources)(assignments[i,r] * cpu[r]) >= min_cpus[i]);

output [ "{" ]
    ++ [ "\"ingredients\" :[" ] 
    ++ [ "\"" ++ "{ \"ingredient\": " ++ show(i)
          ++ ", \"resource: " ++ show(resources[r]) 
                ++ ", \"num_resources\":" ++ show(assignments[i, r]) 
                ++ ", \"region\":" ++ show(regions[r])
                ++ "},"
    ++ "\", " | i in Ingredients, r in Resources ] ++ [ "]," ]
    ++ [ "\"vm_cost\": \"" ++ show_float(-1,2,sum(i in Ingredients, r in Resources)(assignments[i,r] * costs[r]) / 1000.0) ++ "\", " ]
    ++ [ " \"total_cost\": " ++ show(total_cost) ]
    ++ [ "}" ];
