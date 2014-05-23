require File.join(File.dirname(__FILE__), 'helpers')

module WRF_Common

  def run_nice(cmd)
    pp "The system is executing the following command", cmd
    begin
        run_command(cmd)
    rescue
      p $!
      return(false)
    end
    true
  end

  def cp_namlst(nam_lst,tgt)
    puts "Copying Namelist to #{tgt}"
    FileUtils.cp nam_lst, tgt
  end

end

module MPI_Run
  def hostfile
    return {} unless @hostfile
    {"--hostfile" => File.expand_path(@hostfile)}
  end

  def rankfile
    return {} unless @rankfile
    {"--rankfile" => File.expand_path(@rankfile) }
  end

  def def_opts
    { "--mca"=> "btl self,sm,tcp",
      "-np" => 1}
  end

  def run_opts
    def_opts.merge(@mpi_opts).merge(hostfile).merge(rankfile)
  end
end
