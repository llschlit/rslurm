Slurm/SGE
====

Ruby bindings for Simple Linux Utility Management/GridEngine
###UNDER DEVELOPMENT###
Working to abstract scheduler so that either Slurm or SGE can be selected
through a setting with no other implementation changes required.

Classes

+ rschedhost
+ rschedjobs < rschedreq
+ rschedqueue
+ rschedreq

## rschedhost ##
~~~
globalHost = RSchedhost.new("global")

puts "Number of matlab licenses max for cluster: " + globalHost.complex_value(:matlab).to_s
~~~
### Methods ###
+ (array) complex_list
+ (string) complex_value
+ (array) load_list
+ (string) load_value

## rschedjob ##
~~~
jobs = RSchedjob.new

jobs.each do |job|
    puts job.jobid + " " + job.owner + " " + job.state
end
...
1 user1 r
2 user2 r
3 user1 r
4 user3 w
~~~
### Methods (rschedjob) ###
+ each
+ list
+ jobid
+ slots
+ subTime
+ startTime
+ queueName
+ hardReqQueue
+ state
+ owner
+ hardRequestList
+ hardRequest
+ softRequestList
+ softRequest

## rschedqueue ##
~~~
require 'rschedqueue'

queues = RSchedqueue.new

queues.each do |queue|
    puts queue.name.to_s + " " + queue.used.to_s + " " + queue.available.to_s + " " + queue.total.to_s
end
~~~
### Methods (rschedqueue) ###
+ list
+ each
+ name
+ load
+ used
+ reserved
+ available
+ total
+ disabled

## rschedhost ##
Still under development... not expected to work.
