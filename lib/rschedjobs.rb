require 'rschedreq'
require 'time'
require 'rubygems'
require 'rschedjob'
require 'rschedstring'
require 'rschedutil'
include RSchedUtil

# Provides methods for viewing GridEngine job information
class RSchedJobs
  def initialize(user)

  # get user job queue
  (s, error) = execio "squeue -u #{user} --noheader -o '%8i %3t %4p %6q %8P %15j %15u %10a %20V %20S %10M %11l %20B %4C %5D %5m %10v %10n %R'", nil

  # turn list into array for parsing
  a = s.split(" ")
  i = 0
  @@jobs = Hash.new
  jobNumber = 0

  a.each do |elem|
    # for each new job, get the job number and initialize hash
    if (i % 19 == 0)
      jobNumber = elem.to_str
      @@jobs[jobNumber] = Hash.new
      @@jobs[jobNumber][:jobid] = jobNumber
      @@jobs[jobNumber][:hard_requests] = Hash.new
      i = 0
    end

    # parse
    case i
      when 1
        @@jobs[jobNumber][:state] = elem
      when 2
        @@jobs[jobNumber][:priority] = elem
      when 3
        @@jobs[jobNumber][:qos] = elem
      when 4
        @@jobs[jobNumber][:partition] = elem
      when 5
        @@jobs[jobNumber][:job_name] = elem
      when 6
        @@jobs[jobNumber][:job_owner] = elem
      when 7
        @@jobs[jobNumber][:account] = elem
      when 8
        @@jobs[jobNumber][:submission_time] = elem
      when 9
        @@jobs[jobNumber][:start_time] = elem
      when 10
        @@jobs[jobNumber][:time] = elem
      when 11
        @@jobs[jobNumber][:hard_requests][:h_rt] = elem
      when 12
        @@jobs[jobNumber][:exec_host] = elem
      when 13
        @@jobs[jobNumber][:slots] = elem #aka cpus
      when 14
        @@jobs[jobNumber][:hard_requests][:nodes] = elem
      when 15
        @@jobs[jobNumber][:hard_requests][:min_m] = elem
      when 16
        @@jobs[jobNumber][:reservation] = elem
      when 17
        @@jobs[jobNumber][:queue] = elem
      when 18
        @@jobs[jobNumber][:nodelist_reason] = elem
    end
    i += 1
  end

end

# provide an RSchedJob for each job currently active
  def each
    self.list.each do |jobid|
      yield RSchedJob.new @@jobs[jobid]
    end
  end

  def where_id_is(jobid)
    if @@jobs.has_key?(jobid)
      RSchedJob.new @@jobs[jobid]
    else
      nil
    end
  end

  def each_when_name_is(name)
    @@jobs.keys.each { |jobid| yield RSchedJob.new :jobid => jobid if @@jobs[jobid][:job_name] == name }
  end

  def each_when_state_is(state)
    @@jobs.keys.each { |jobid| yield RSchedJob.new :jobid => jobid if @@jobs[jobid][:state] == state }
  end

  def each_when_owner_is(owner)
    @@jobs.keys.each { |jobid| yield RSchedJob.new :jobid => jobid if @@jobs[jobid][:job_owner] == owner }
  end

  def to_hash
    @@jobs
  end

  def count
    @@jobs.keys.count
  end

  # provide an array of the current job ids
  def list
    @@jobs.keys
  end

end
