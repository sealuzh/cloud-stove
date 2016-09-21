begin
kanban_app_instance = Ingredient.seed_with!(name: 'Real-time, multi-user Kanban Board') do |i|
  i.body = <<-EOT
*Lifted from https://github.com/eventuate-examples/es-kanban-board*

This sample application, which is written in Java and uses Spring Boot,
demonstrates how you can use the [Eventuate&trade;
Platform](http://eventuate.io/) to build a real-time, multi-user collaborative
application. The Kanban Board application enables users to collaboratively
create and edit Kanban boards and tasks. Changes made by one user to a board or
a task are immediately visible to other users viewing the same board or task.

The Kanban Board application is built using
[Eventuate&trade;'s](http://eventuate.io/) Event Sourcing based programming
model, which is ideally suited for this kind of application. The application
persists business objects, such as `Boards` and `Tasks`, as a sequence of state
changing events. When a user creates or updates a board or task, the
application saves an event in the event store. The event store delivers each
event to interested subscribers. The Kanban application has a event subscriber
that turns each event into WebSocket message that trigger updates in each
user's browser.

# Architecture

The following diagram shows the application architecture:

![](https://github.com/eventuate-examples/es-kanban-board/raw/master/eventuate-kanban-architecture.png#img-fluid)

The application consists of the following:

* AngularJS browser application
* Kanban Server - a Java and Spring Boot-based server-side application.
* MongoDB database - stores materialized views of boards and tasks

The Kanban Board server has a Spring MVC-based REST API for creating, updating
and querying Kanban boards and tasks. It also has a STOMP-over-WebSocket API,
which pushes updates to boards and tasks to the AngularJS application. It can
be deployed as either a monolithic server or as a set of microservices. Read on
to find out more.

# Kanban Board Server design

The Kanban Board server is written using the [Eventuate Client Framework for Java](http://eventuate.io/docs/java/eventuate-client-framework-for-java.html), which provides an event sourcing based programming model for Java/Spring-Boot aplications.
The server persists boards and tasks as events in the [Eventuate event store](http://eventuate.io/howeventuateworks.html).
The Kanban Board server also maintains a materialized view of boards and tasks in MongoDB.

The following diagram shows the design of the server:

![](https://github.com/eventuate-examples/es-kanban-board/raw/master/eventuate-kanban-server.png#img-fluid)

The application is structured using the Command Query Responsibility Segregation (CQRS) pattern.
It consists of the following modules:

*  Command-side module - it handles requests to create and update (e.g. HTTP POST, PUT and DELETE requests) boards and tasks.
The business logic consists of event sourcing based `Board` and `Command` aggregates.

* Query-side module - it handles query requests (ie. HTTP GET requests) by querying a MongoDB materialized view that it maintains.
It consists of an event handler that subscribes to Board and Task events and updates MongoDB.

* WebSocket gateway - it subscribes to Board and Task events published by the event store and republishes them as web socket events.

# Deploy as a monolith or as microservices

The server can either be deployed as a monolith (as shown in the above diagram) or it can be deployed as microservices. The following diagram shows the microservice architecture.

![](https://github.com/eventuate-examples/es-kanban-board/raw/master/eventuate-kanban-microservices.png#img-fluid)

There are the following services:

* API Gateway - routes REST requests to the appropriate backend server, and translates event store events into WebSocket messages.
* Board command side - creates and updates Boards
* Board query side - maintains a denormalized view of boards
* Task command side - creates and updates Tasks
* Board query side - maintains a denormalized view of tasks
  EOT
  
  apigw = i.children.seed_with!(name: 'API Gateway') do |c|
    c.body = 'Routes REST requests to the appropriate backend server, and translates event store events into WebSocket messages.'
    c.constraints.seed_with!(type: RamConstraint.to_s) { |rc| rc.min_ram = 2453 }
    c.constraints.seed_with!(type: CpuConstraint.to_s) { |rc| rc.min_cpus = 1 }
  end
  
  bcs = i.children.seed_with!(name: 'Board: Command Side') do |c|
    c.body = 'Creates and updates Boards'
    c.constraints.seed_with!(type: RamConstraint.to_s) { |rc| rc.min_ram = 2832 }
    c.constraints.seed_with!(type: CpuConstraint.to_s) { |rc| rc.min_cpus = 1 }
  end
  
  bqs = i.children.seed_with!(name: 'Board: Query Side') do |c|
    c.body = 'Maintains a denormalized view of boards'
    c.constraints.seed_with!(type: RamConstraint.to_s) { |rc| rc.min_ram = 6192 }
    c.constraints.seed_with!(type: CpuConstraint.to_s) { |rc| rc.min_cpus = 2 }
  end
  
  tcs = i.children.seed_with!(name: 'Task: Command Side') do |c|
    c.body = 'Creates and updates Tasks'
    c.constraints.seed_with!(type: RamConstraint.to_s) { |rc| rc.min_ram = 4832 }
    c.constraints.seed_with!(type: CpuConstraint.to_s) { |rc| rc.min_cpus = 1 }
  end
  
  tqs = i.children.seed_with!(name: 'Task: Query Side') do |c|
    c.body = 'Maintains a denormalized view of tasks'
    c.constraints.seed_with!(type: RamConstraint.to_s) { |rc| rc.min_ram = 9192 }
    c.constraints.seed_with!(type: CpuConstraint.to_s) { |rc| rc.min_cpus = 2 }
  end
  
  es = i.children.seed_with!(name: 'Event Store') do |c|
    c.body = 'The event store'
    c.constraints.seed_with!(type: RamConstraint.to_s) { |rc| rc.min_ram = 26792 }
    c.constraints.seed_with!(type: CpuConstraint.to_s) { |rc| rc.min_cpus = 4 }
  end
  
  db = i.children.seed_with!(name: 'MongoDB') do |c|
    c.body = 'MongoDB backend to cache denormalized views'
    c.constraints.seed_with!(type: RamConstraint.to_s) { |rc| rc.min_ram = 16792 }
    c.constraints.seed_with!(type: CpuConstraint.to_s) { |rc| rc.min_cpus = 2 }
  end
  
  [ bcs, bqs, tcs, tqs ].each do |c|
    # API GW -> all CQRS components
    apigw.constraints_as_source.seed_with!(type: DependencyConstraint.to_s, target_id: c.id)
    
    # CQRS components -> event store
    c.constraints_as_source.seed_with!(type: DependencyConstraint.to_s, target_id: es.id)
  end
  
  [ bqs, tqs ].each do |c|
    # Query compnents -> MongoDB
    c.constraints_as_source.seed_with!(type: DependencyConstraint.to_s, target_id: db.id)
  end
end
end
