require 'rschedreq'
require 'time'
require 'rubygems'
require 'rschedjobs'
require 'rschedutil'

# Provides methods for viewing GridEngine job information
class RSchedJob
  # no-brainer accessors
  # 
  attr_accessor :jobid, :job_name, :slots, :submission_time, :start_time, :queue,
                :state, :job_owner, :pe, :pe_slots, :reservation, :cwd, :wd,
                :hard_resreq, :soft_resreq, :joinout, :outfile, :errfile, :script,
                :queue_name, :valid, :hard_requests, :soft_requests

  # In an 'overloaded' way, create the object based on whether an argument
  # is provided.  This will let us create either a base object with the current
  # job list or provide an object populated with a specific job's data
  def initialize(*args)
    extend RSchedUtil

    yield self if block_given?

    if (args[0] != nil)
      conf = args[0]
    else
      conf = Hash.new
    end

    raise ArgumentError, "Argument is not a hash! #{conf.class} #{conf}" if conf.class != Hash

    # We're a valid job unless we run into some condition
    self.valid = true

    if conf.has_key?(:jobid)
      parse_job_by_id conf
    end
  end
    
  # Submit our job...

  def submit
    # resource requests
    if self.hard_requests != nil
      reqs = Array.new
      self.hard_requests.keys.each { |cplx| reqs << cplx.to_s + "=" + self.hard_requests[cplx].to_s }
      h_res_req = reqs * " "
      self.hard_resreq = Hash[*reqs.flatten]
    end


    # build our command-line arguments from our accessor info
    cmdargs = Array.new
    cmdargs << h_res_req                      if defined?(h_res_req)
    cmdargs << s_res_req                      if defined?(s_res_req)
    cmdargs << "-o #{self.outfile}"           if self.outfile != nil
    cmdargs << "-e #{self.errfile}"           if self.errfile != nil
    cmdargs << "--job-name=#{self.job_name}"  if self.job_name != nil
    cmdargs << "--workdir=#{self.wd}"         if self.wd != nil
    cmdargs << "--nodelist=#{self.queue}"     if self.queue != nil

    # we're going to submit a job
    (status,error) = execio "sudo -u #{self.job_owner} sbatch " + cmdargs * " ", self.script

    # check status
    if status.class == String and status.match(/^Submitted batch job [0-9]+$/)
      jobs = RSchedJobs.new self.job_owner
      jobs = jobs.to_hash
      parse_job_by_id (jobs[status.match(/[0-9]+/).to_s])
      return 0 
    else
      raise RuntimeError, "Job submission to Slurm failed! => #{status} #{error}"
      return nil
    end
  end
  
  # Gotta be able to delete jobs, too
  def delete
    (status,error) = execio "sudo -u #{self.job_owner} scancel #{self.jobid}", nil
    if error.include? "scancel: error:" 
      raise RuntimeError, "Deletion of job #{self.jobid} failed!"
      return nil
    else
      self.state = "d"
      puts "Job successfully deleted."
      return 0
   end
  end

  private
#---------

  def parse_job_by_id(job)
  # We're providing a job and its info

    if job == nil
      self.valid = false
      return self
    end

    self.jobid          = job[:jobid]           if job.has_key?(:jobid)
    self.job_name       = job[:job_name]        if job.has_key?(:job_name)
    self.slots          = job[:slots]           if job.has_key?(:slots)
    self.submission_time= job[:submission_time] if job.has_key?(:submission_time)
    self.start_time     = job[:start_time]      if job.has_key?(:start_time)
    self.queue          = job[:queue]           if job.has_key?(:queue)
    self.state          = job[:state]           if job.has_key?(:state)
    self.job_owner      = job[:job_owner]       if job.has_key?(:job_owner)
    self.reservation    = job[:reservation]     if job.has_key?(:reservation)
    self.joinout        = (self.errfile == nil ? true : false)
    self.queue_name     = job[:queue_name]      if job.has_key?(:queue_name)
    self.hard_requests  = job[:hard_requests]   if job.has_key?(:hard_requests)
    self.script         = job[:script]          if job.has_key?(:script)
  end

end
