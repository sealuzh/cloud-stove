include "globals.mzn";

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

% Resource prices per month in mUSD
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

% Maximum number of resources for each ingredient
array[Ingredients] of int: max_num_resources;

%
% Decision variables
%

% Component assignment
int: max_num_assignments = ceil(max(max(min_ram) / max(1, min(ram)), max(min_cpus) / max(1, min(cpu))));
array[Ingredients] of var Resources: assigned_resources;
array[Ingredients] of var 1..max_num_assignments: num_assigned_resources;

int: max_costs = max_num_assignments * max(costs);
array[Ingredients] of var min(costs)..max_costs: assignment_costs;

% Total Deployment Cost
var min(costs)..(num_ingredients * max_costs): total_cost;

% Minimize total cost
solve %:: int_search(num_assigned_resources ++ assignment_costs ++ ingredient_ram ++ ingredient_cpu, smallest, indomain_min, complete)
  minimize total_cost;

%
% Constraints
%

% Cost of resource assignment per ingredient
constraint forall(i in Ingredients)(
  assignment_costs[i] == num_assigned_resources[i] * costs[assigned_resources[i]]
);

% Calculate total cost
constraint total_cost =
  % Resource cost
  sum(i in Ingredients)(
    assignment_costs[i] + traffic_costs[i] + num_assigned_resources[i]
    % num_assigned_resources is part of the objective function as a tie breaker.
    % If multiple optimal solutions exist, we prefer the one with the least resources.
  );

% Chosen resources must be in the preferred region
% constraint forall(i in Ingredients, r in Resources where preferred_regions[i,r] == false)(
%   assigned_resources[i] != r
% );
constraint forall(i in Ingredients)(preferred_regions[i, assigned_resources[i]] == true);


% Chosen resources must have enough RAM
array[Ingredients] of var min(ram)..(max(ram)*max_num_assignments): ingredient_ram;
constraint forall(i in Ingredients)(
  ingredient_ram[i] == num_assigned_resources[i] * ram[assigned_resources[i]]
  /\ ingredient_ram[i] >= min_ram[i]
);

% Chosen resources must have enough CPU cores
array[Ingredients] of var min(cpu)..max(cpu)*max_num_assignments: ingredient_cpu;
constraint forall(i in Ingredients)(
  ingredient_cpu[i] == num_assigned_resources[i] * cpu[assigned_resources[i]]
  /\ ingredient_cpu[i] >= min_cpus[i]
);

% Transfer costs
array[Ingredients] of var int: traffic_costs;
constraint forall(i in Ingredients)(
  traffic_costs[i] == sum(j in Ingredients where inter_ingredient_traffic[i,j] > 0)(
    inter_ingredient_traffic[i,j] * transfer_costs[assigned_resources[i], assigned_resources[j]]
  )
);

% Restrict number of assigned resources
constraint forall(i in Ingredients)(
  max_num_resources[i] == 0 \/ num_assigned_resources[i] <= max_num_resources[i]
);

% Always assign at least two resources 
%   (could also be enabled using an additional parameter, e.g. 
%     array[Ingredients] of bool: force_distributed
% constraint forall(i in Ingredients where force_distributed[i])(num_assigned_resources[i] > 1);

% All resources in the same region
% array[Resources] of var min(lb_array(regions), 0)..ub_array(regions): selected_regions;
% constraint forall(r in [ assigned_resources[i] | i in Ingredients])(
%   selected_regions[r] == regions[r]
% ) /\ nvalue(selected_regions) <= 2;
% var dom_array(regions): selected_region;
% constraint forall(r in [ assigned_resources[i] | i in Ingredients])(
%   regions[r] == selected_region
% );
% constraint all_equal([ regions[assigned_resources[i]] | i in Ingredients]);

% output [ "{" ]
%     ++ [ "\"ingredients\": [ {}" ] 
%     ++ [ ", \n{ \"ingredient\": \"" ++ show(i) ++ "\""
%           ++ ", \"count\": \"" ++ show(num_assigned_resources[i]) ++ "\""
%           ++ ", \"resource\": \"" ++ show(resources[assigned_resources[i]]) ++ "\""
%           ++ ", \"region\": \"" ++ show(regions[assigned_resources[i]]) ++ "\""
%           ++ "}"
%     | i in Ingredients ] ++ [ "]," ]
%     ++ [ "\n"]
%     ++ [ "\"vm_cost\": \"" ++ show_float(-1,2,sum(i in Ingredients)(assignment_costs[i]) / 1000.0) ++ "\", " ]
%     ++ [ " \"total_cost\": " ++ show(total_cost) ]
%     ++ [ " \"total_ram\":" ++ show(sum(i in Ingredients)(ingredient_ram[i])) ]
%     ++ [ " \"total_cpu\":" ++ show(sum(i in Ingredients)(ingredient_cpu[i])) ]
%     ++ [ "}" ] ++ [ 
%     "\ningredient: " ++ show(i)
%     ++ ", cpu: " ++ show(ingredient_cpu[i])
%     ++ ", ram: " ++ show(ingredient_ram[i])
%     ++ ", min_cpu: " ++ show(min_cpus[i])
%     ++ ", min_ram: " ++ show(min_ram[i])
%     ++ ", traffic_costs: " ++ show(traffic_costs[i])
%     ++ ", costs: " ++ show_float(1, 2, assignment_costs[i] / 1000.0)
%     | i in Ingredients ]
%     ++ [ ",\nmax_num_assignments: " ++ show(max_num_assignments) 
%     ++ ", max_costs: " ++ show(max_costs)
%     ];

output [ "{" ]
    ++ [ "\"ingredients\" :[" ] ++ [ "\"" ++ show(resources[assigned_resources[i]]) ++ "\", " | i in Ingredients ] ++ [ "]," ]
    ++ [ "\"num_resources\" :[" ] ++ [ "\"" ++ show(num_assigned_resources[i]) ++ "\", " | i in Ingredients ] ++ [ "]," ]
    ++ [ "\"regions\" :[" ] ++ [ show(regions[assigned_resources[i]]) ++ ", " | i in Ingredients ] ++ [ "]," ]
    ++ [ "\"vm_cost\": \"" ++ show_float(-1,2,sum(i in Ingredients)(assignment_costs[i]) / 1000.0) ++ "\", " ]
    ++ [ " \"total_cost\": " ++ show(total_cost) ]
    ++ [ "}" ];
