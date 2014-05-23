require File.join(File.dirname(__FILE__), 'wrf_configuration')

class RunWPS
  def initialize(inlist, opt=:mpi)
    @conf = WRFConfiguration.new(inlist)
    @opt = opt
  end
  
  def ungrib
    WPS.new(@conf,executable="ungrib",@opt)
  end

  def geogrid
    WPS.new(@conf,executable="geogrid",@opt)
  end

  def metgrid
    WPS.new(@conf,executable="metgrid",@opt)
  end
end

module PreCommon
  def setup(flag,which_mpi)
    infiles = (flag ? lbc_files : nil)
    args = [ conf.pre_path,     # preprocess directory
             conf.bin_path,     # executable directory
             infiles,          # unused for now
             conf.vtable,       # which vtable to use
             conf.wps_namelist, # location of namelist.wps
             {"-np" => 1}   ]
   case which_mpi
      when :mpi
        WRF_MPI_Pre.new(*args)
      when :mpi_ib
        WRF_MPI_IB_Pre.new(*args)
      when :mpi_eth
        WRF_MPI_Eth_Pre.new(*args)
      when :no_mpi
        WRF_Pre.new(*args)
      end
  end
private
  def lbc_files
    path     = conf.lbc_path
    files   = IO.readlines(conf.lbc_files)
    files.map! {|f| File.join path, f.chomp}
  end
end

class WPS
  include PreCommon
  attr_reader :conf, :rstatus
  def initialize(conf,executable,which_mpi)
    @conf = conf
    @executable = executable
    @rstatus = false
    if @executable == "ungrib"
      @wps = setup(true,which_mpi)
    else
      @wps = setup(false,which_mpi)
    end 
  end

  def run
    case @executable
      when "ungrib"
        ungrib_setup
      else
        wps_setup
    end
    puts "Now running "+@executable
    @rstatus=(@wps.run_exe @executable)
    self
  end
  def ungrib_setup
    all_present   = lbc_files.all? {|f| File.exist? f}
    unless all_present
      missing = lbc_files.find_all {|f| not (File.exist?(f))}
      puts "The following files are missing"
      puts  missing
      puts "\t Please add them to #{conf.lbc_path} and try again"
    end
    abort "Some input files are not present; eXit" unless all_present
    @wps.setup
  end

  def wps_setup
    @wps.mk_work_dir
    @wps.copy_namelists
  end
  
  def cleanup
    p "to clean or not to"
    @wps.clean if @rstatus
    "not " if not @rstatus
  end

  def method_missing(name,*args)
    case name.to_s
      when /hostfile|run_cmd|run_opts|mpi_opts/
        @wps.send(name, *args)
      else
        abort "#{name}(#{args}) is not a valid command"
      end 
  end
end
