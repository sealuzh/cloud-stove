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

%
% Decision variables
%

% Component assignment
int: max_num_assignments = ceil(max(max(min_ram) / min(ram), max(min_cpus) / min(cpu)));
array[Ingredients, Resources] of var 0..max_num_assignments: assignments;

int: max_costs = max_num_assignments * max(costs);
array[Ingredients] of var min(costs)..max_costs: assignment_costs;

% Total Deployment Cost
var min(costs)..(num_ingredients * max_costs): total_cost;

% Minimize total cost
solve %:: int_search(assignment_costs ++ ingredient_ram ++ ingredient_cpu ++ [assignments[i,r] | i in Ingredients, r in Resources], smallest, indomain_min, complete)
  minimize total_cost;

%
% Constraints
%

% Cost of resource assignment per ingredient
constraint forall(i in Ingredients)(
  assignment_costs[i] == sum(r in Resources)(assignments[i,r] * costs[r])
);

% Calculate total cost
constraint total_cost =
  % Resource cost
  sum(i in Ingredients)(assignment_costs[i] %+ traffic_costs[i]
  );

% Chosen resources must be in the preferred region
constraint forall(i in Ingredients, r in Resources where preferred_regions[i,r] == false)(
  assignments[i,r] == 0
);

% Chosen resources must have enough RAM
array[Ingredients] of var 1..(max(ram)*max_num_assignments): ingredient_ram;
constraint forall(i in Ingredients)(
  ingredient_ram[i] == sum(r in Resources)(assignments[i,r] * ram[r]) 
  /\ ingredient_ram[i] >= min_ram[i]
);

% Chosen resources must have enough CPU cores
array[Ingredients] of var 1..max(cpu)*max_num_assignments: ingredient_cpu;
constraint forall(i in Ingredients)(
  ingredient_cpu[i] == sum(r in Resources)(assignments[i,r] * cpu[r]
) /\ ingredient_cpu[i] >= min_cpus[i]);

% constraint forall(i in Ingredients)(
%   forall(r in Resources where assignments[i,r] > 0)(
%     assignments[i,r] = ceil(max(min_ram[i] / ram[r], min_cpus[i] / cpu[r]))
%   )
% );

% Transfer costs
% array[Ingredients] of var int: traffic_costs;
% constraint forall(i in Ingredients)(
%   traffic_costs[i] == sum(ri in Resources where assignments[i,ri] > 0)(
%     sum(j in Ingredients where inter_ingredient_traffic[i,j] > 0)(
%       inter_ingredient_traffic[i,j] * sum(rj in Resources where assignments[j,rj] > 0)(transfer_costs[ri,rj])
%     )
%   )
% );

% All resources in the same region
array[Resources] of var min(lb_array(regions), 0)..ub_array(regions): selected_regions;
constraint forall(r in Resources)(
  selected_regions[r] == if (max(col(assignments, r)) > 0) then regions[r] else 0 endif
) /\ nvalue(selected_regions) <= 2;

% Only a limited number of different resource per ingredient?
constraint forall(i in Ingredients)(nvalue(row(assignments, i)) <= 2);

output [ "{" ]
    ++ [ "\"ingredients\": [ {}" ] 
    ++ [ ", \n{ \"ingredient\": \"" ++ show(i) ++ "\""
          ++ ", \"count\": \"" ++ show(assignments[i, r]) ++ "\""
          ++ ", \"resource\": \"" ++ show(resources[r]) ++ "\""
          ++ ", \"region\": \"" ++ show(regions[r]) ++ "\""
          ++ "}"
    | i in Ingredients, r in Resources ] ++ [ "]," ]
    ++ [ "\n"]
    ++ [ "\"vm_cost\": \"" ++ show_float(-1,2,sum(i in Ingredients, r in Resources)(assignments[i,r] * costs[r]) / 1000.0) ++ "\", " ]
    ++ [ " \"total_cost\": " ++ show(total_cost) ]
    ++ [ " \"total_ram\":" ++ show(sum(i in Ingredients, r in Resources)(assignments[i,r] * ram[r])) ]
    ++ [ " \"total_cpu\":" ++ show(sum(i in Ingredients, r in Resources)(assignments[i,r] * cpu[r])) ]
    ++ [ "}" ] ++ [ 
    "\ningredient: " ++ show(i)
    ++ ", cpu: " ++ show(ingredient_cpu[i])
    ++ ", ram: " ++ show(ingredient_ram[i])
    ++ ", min_cpu: " ++ show(min_cpus[i])
    ++ ", min_ram: " ++ show(min_ram[i])
    | i in Ingredients ]
    ++ [ ",\nmax_num_assignments: " ++ show(max_num_assignments) 
    ++ ", max_costs: " ++ show(max_costs)
    ];
