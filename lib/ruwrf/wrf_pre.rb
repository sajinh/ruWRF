require File.join File.dirname(__FILE__), 'wrf_libs'
require 'fileutils'

class WRF_Pre
  include WRF_Common
  attr_reader :run_dir, :wrf_bin
  attr_accessor :run_cmd, :mpi_opts
  def initialize(run_dir,wrf_bin, input_files, vtable, nam_lst,opts={})
    @run_dir     = File.expand_path run_dir
    @wrf_bin     = File.expand_path wrf_bin
    @input_files = input_files
    @vtable      = File.expand_path vtable
    @nam_lst     = File.expand_path nam_lst
    @mpi_opts    = mpi_opts
    @run_cmd     = ""
  end

  def files
    @input_files.map {|f| File.expand_path(f)}
  end

  def rmlinks(lnkdir)
    puts "..."
    puts lnkdir
    FileUtils.rm Dir.glob("#{lnkdir}/GRIBFILE.A*")
  end

  def lnkdir
    @run_dir
  end

  def mklinks  #(files,lnkdir)
    rmlinks(lnkdir)
    lnk="AAA"
    files.each do |file|
      FileUtils.ln_s file, File.join(lnkdir,"GRIBFILE.#{lnk}")
      lnk.next!
    end
  end

  def ln_vtable
    FileUtils.ln_s @vtable, "#{run_dir}/Vtable", :force=>true 
  end

  def mk_work_dir
    FileUtils.mkdir run_dir unless File.exist? run_dir
  end

  def copy_namelists
    cp_namlst(@nam_lst,run_dir)
  end

  def setup
    mk_work_dir
    ln_vtable
    copy_namelists
    mklinks #(files,run_dir)
  end

  def clean
    FileUtils.rm Dir.glob("#{run_dir}/*.log.*")
  end

  def run_exe(prog_name)
    Dir.chdir(run_dir) do
      run_nice("#{wrf_bin}/#{prog_name}.exe")
    end
  end

end

class WRF_MPI_Pre < WRF_Pre
  include MPI_Run
  attr_writer :hostfile, :rankfile
  def initialize(a,b, c, d, e,f)
    super(a,b,c,d,e,f)
    @run_cmd="mpirun"
  end

  def run_exe(prog_name)
    opts = run_opts.to_a.flatten.join " "
    Dir.chdir(run_dir) do
      run_nice("#{run_cmd} #{opts} #{wrf_bin}/#{prog_name}.exe".strip)
    end
  end
end

class WRF_MPI_IB_Pre < WRF_MPI_Pre
  def def_opts
    { "--mca"=> " btl openib,self,sm --mca btl_openib_cpc_include rdmacm --bind-to-core",
      "-np" => 1}
  end
  def ext_opts
    { "--mca"=> "btl_openib_verbose 1 --mca btl ^tcp --bind-to-core",
      "-np" => 1}
  end


end

class WRF_MPI_Eth_Pre < WRF_MPI_Pre
  def def_opts
    { "--mca"=> "btl ^openib --mca btl_tcp_if_include eth0 ",
      "-np" => 1}
  end
end
