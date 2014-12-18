# Code shamelessly lifted from Sean O'halpin
# http://www.ruby-forum.com/topic/2189875
#
require "open3"

module RSchedUtil
    # Say we have an object variable that's a hash.  We might want
    # accessors for a bunch of its keys, right?
    def hash_accessor(hash_name, *key_names)
        key_names.each do |key_name|
            define_method key_name do
                instance_variable_get("@#{hash_name}")[key_name]
            end
            define_method "#{key_name}=" do |value|
                instance_variable_get("@#{hash_name}")[key_name] = value
            end
        end
    end
    def execio(cmd, input)
        output = ""
        error  = ""

        stdin, stdout, stderr, wait_thr = Open3.popen3(cmd, :chdir => "/tmp")

        pid = wait_thr[:pid]

        if input != nil
          stdin.puts input
        end

        stdin.close

        stdout.each_line { |line| output += line }
        stderr.each_line { |line| error += line }

        stdout.close
        stderr.close

        exit_status = wait_thr.value

        return [output,error]
    end
end
