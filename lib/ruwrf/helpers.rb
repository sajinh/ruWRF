require 'open3'

def fcast_init_mismatch_msg(hour)
  "
   Your forecast starts at #{hour}
   Forecasts are usually issued at UTC hours 00 06 12 18 - please
   start your forecast at exactly one of these hours

   "
end

def secs_per_hr
  60*60
end

def secs_per_dy
  24*secs_per_hr
end

def system_run(cmd)
  basename=File.basename(cmd)
  puts "Running cmd :: #{basename}"
  if basename=="ungrib.exe"
    system(cmd)
    return
  end
  fout = File.open("#{basename}.stdout","w")
  ferr = File.open("#{basename}.stderr","w")
  fout.sync = true

  Open3.popen3(cmd) do |stdin, stdout, stderr|
   
    ferr.puts stderr.read
    sout =  stdout.read
    fout.puts sout
  end
  fout.flush
  fout.fsync 
  fout.close
  ferr.close
end

class Command
  def self.run(cmd)
 output=""
  pp cmd
  pipe=IO.popen("#{cmd} 2>&1","w+")
  if pipe
    while !pipe.eof? do
      output+=pipe.gets
    end
    Process.wait(pipe.pid)
    if $?.signaled?
      exit_status=$?.termsig
    elsif $?.exited?
      exit_status=$?.exitstatus
    end
  else
    raise "ERROR! Could not open pipe to #{cmd}"
  end
  return [output,exit_status]
  end
end

def run_command(cmd)
  output = Command.run(cmd)
  if output[1] != 0
    raise output[0]
  end
end
