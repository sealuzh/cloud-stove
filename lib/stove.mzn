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
array[Resources] of string: resource_ids;

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
array[Ingredients] of var 1..num_resources: assignments;

% Total Deployment Cost
var int: total_cost;

% Minimize total cost
solve %:: int_search(assignments, first_fail, indomain_min, complete)
  minimize total_cost;

%
% Constraints
%

% Calculate total cost
constraint total_cost = 
  % Resource cost
  sum(i in Ingredients)(
    costs[assignments[i]]
  ) + 
  % Communication costs
  sum(i in Ingredients, j in Ingredients)(
    inter_ingredient_traffic[i,j] * transfer_costs[assignments[i],assignments[j]]
  );

% Chosen resources must be in the preferred region
constraint forall(i in Ingredients)(preferred_regions[i, assignments[i]] == true);

% Chosen resources must have enough RAM
constraint forall(i in Ingredients)(ram[assignments[i]] >= min_ram[i]);

% Chosen resources must have enough CPU cores
constraint forall(i in Ingredients)(cpu[assignments[i]] >= min_cpus[i]);

output [ "{" ]
    ++ [ "\"ingredients\" :[" ] ++ [ "\"" ++ show(resource_ids[assignments[i]]) ++ "\", " | i in Ingredients ] ++ [ "]," ]
    ++ [ "\"regions\" :[" ] ++ [ show(regions[assignments[i]]) ++ ", " | i in Ingredients ] ++ [ "]," ]
    ++ [ "\"vm_cost\": \"" ++ show_float(-1,2,sum(i in Ingredients)(costs[assignments[i]]) / 1000.0) ++ "\", " ]
    ++ [ " \"total_cost\": " ++ show(total_cost) ]
    ++ [ "}" ];
