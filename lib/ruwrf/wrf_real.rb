require File.join File.dirname(__FILE__), 'wrf_libs'
require 'fileutils'

class WRF_Real
  include WRF_Common
  attr_reader :run_dir, :wrf_tbl, :wrf_bin
  attr_accessor :run_cmd, :mpi_opts
  def initialize(run_dir, wrf_bin, pre_dir, wrf_tbl, nam_lst,opts={})
    @run_dir=File.expand_path run_dir
    @wrf_bin=File.expand_path wrf_bin
    @pre_dir=File.expand_path pre_dir
    @wrf_tbl=File.expand_path wrf_tbl
    @nam_lst=File.expand_path nam_lst
    @mpi_opts = opts
    @run_cmd=""
  end

  def cp_wrf_tables
    puts "Copying WRF Tables unless they are absent"
    Dir.glob(wrf_tbl+"/*").each do |fil|
     local_fil=File.join run_dir, File.basename(fil)
      FileUtils.cp(fil,run_dir) unless File.exist? local_fil
    end
  end

  def ln_met_files
    puts "Linking in met*nc files"
    FileUtils.ln_s Dir.glob("#{@pre_dir}/met*.nc"), run_dir
  end

  def unln_met_files
    FileUtils.rm_f Dir.glob "#{run_dir}/met*.nc"
  end

  def copy_namelist
    cp_namlst(@nam_lst,run_dir)
  end

  def run
    FileUtils.mkdir run_dir unless File.exist? run_dir
    cp_wrf_tables
    #unln_met_files
    #ln_met_files
    copy_namelist
    run_real
  end

  def run_real
    Dir.chdir(run_dir) do
      run_nice("#{wrf_bin}/real.exe")
    end
  end

  def clean
    FileUtils.mv "rsl.out.0000", "metgrid.log" if File.exist? "rsl.out.0000"
    #unln_met_files
    rm_rsl_logs
  end

  def rm_rsl_logs
    FileUtils.rm_f Dir.glob "#{run_dir}/rsl.*"
  end
end

class WRF_MPI_Real < WRF_Real
  include MPI_Run
  attr_writer :hostfile, :rankfile
  def initialize(a,b, c, d, e,f)
    super(a,b,c,d,e,f)
    @run_cmd="mpirun"
  end

  def run_real
    opts = run_opts.to_a.flatten.join " "
    Dir.chdir(run_dir) do
      run_nice("#{run_cmd} #{opts} #{wrf_bin}/real.exe".strip)
    end
  end
end
class WRF_MPI_IB_Real < WRF_MPI_Real
 def def_opts
    { "--mca"=> " btl openib,self,sm --mca btl_openib_cpc_include rdmacm --bind-to-core",
      "-np" => 1}
  end
  def ext_opts
    { "--mca"=> "btl_openib_verbose 1 --mca btl ^tcp --bind-to-core",
      "-np" => 1}
  end
end

class WRF_MPI_Eth_Real < WRF_MPI_Real
  def def_opts
    { "--mca"=> "btl ^openib --mca btl_tcp_if_include eth0 ",
      "-np" => 1}
  end
end

