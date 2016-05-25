% Number of (atomic) ingredients, i.e., components to be deployed
int: num_ingredients;
set of int: Ingredients = 1..num_ingredients;

% Number of available providers
% int: num_providers;
% OR:
% Number of available regions across all providers
% int: num_regions;

% Total number of resources available for deployment
int: num_resources;
set of int: Resources = 1..num_resources;

% [1..num_resources] or [Resources] arrays are ordered and represent 
% all resources available for deployment across all providers, across
% all regions (hopefully this does not get too big to solve)

% Resource IDs
array[Resources] of string: resource_ids;

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
array[Ingredients, Ingredients] of int: inter_component_traffic;

% Component RAM requirements
array[Ingredients] of int: min_ram;

%
% Decision variables
%

% Component assignment
array[Ingredients] of var 1..num_resources: assignments;

% Total Deployment Cost
int: max_total = num_ingredients * max(costs);
var 0..max_total: total_cost;

% Minimize total cost
solve :: int_search(assignments, smallest, indomain_min, complete)
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
    inter_component_traffic[i,j] * transfer_costs[assignments[i],assignments[j]]
  );
  
% Chosen resources must have enough RAM
constraint forall(i in Ingredients)(ram[assignments[i]] >= min_ram[i]);

output [ show(resource_ids[assignments[i]]) ++ ", " | i in Ingredients ] ++
            [ "vm cost: " ++ show_float(-1,2,sum(i in Ingredients)(costs[assignments[i]]) / 1000.0) ++ ", " ] ++
            [ " total cost: " ++ show(total_cost) ++ "\n" ];

% Data

% Sample: 2-tier app, 2 providers
num_ingredients = 4;

% num_resources = 4;

% resource_ids = ["t2.nano", "m3.medium", "f1-micro", "n1-standard-1"];
% costs in mUSD/month
% costs = [4040, 49850, 4690, 28640];
% RAM in MB
% ram = [512, 3840, 614, 3840];
% cpu = [0, 1, 0, 1];

% transfer costs in mUSD/GB
% transfer_costs = 
%    [| 0, 0, 90, 90,
%    | 0, 0, 90, 90,
%    | 120, 120, 0, 0
%    | 120, 120, 0, 0 |];

% Traffic between components (GB)
inter_component_traffic =
   [| 0, 100, 100, 0,
    | 100, 0, 0, 100,
    | 100, 0, 0, 100,
    | 0, 0, 100, 100 |];

min_ram = [2280, 4512, 2123, 12823];
