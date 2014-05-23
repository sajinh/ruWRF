require File.join(File.dirname(__FILE__), 'wrf_configuration')

class RunWRF
  def initialize(inlist,opt=:mpi)
    @conf = WRFConfiguration.new(inlist)
    @opt = opt
  end
  
  def real
    Real.new(@conf,@opt)
  end

  def wrf
    WRF.new(@conf,@opt)
  end
end

class Real
  attr_reader :conf
  def initialize(conf,which_mpi)
    @conf = conf
    @rstatus = false
    @real = setup(which_mpi)
  end
  def setup(which_mpi)
    args = [conf.run_path,     # run directory
            conf.bin_path,     # executable directory
            conf.pre_path,     # preprocess directory
            conf.tbl_path,     # path to misc. tables
            conf.wrf_namelist, # location of namelist.input
            {"-np" => 1}   ]    
    case which_mpi 
      when :mpi
        WRF_MPI_Real.new(*args)
      when :mpi_ib
        WRF_MPI_IB_Real.new(*args)
      when :mpi_eth
        WRF_MPI_Eth_Real.new(*args)
      end
  end
  def run
    @rstatus=@real.run
    self
  end
  
  def cleanup
    p "to clean or not to"
    @real.clean if @rstatus
    "not " if not @rstatus
  end

  def method_missing(name,*args)
    case name.to_s
      when /hostfile|run_cmd|run_opts|mpi_opts/
        @real.send(name, *args)
      else
        abort "#{name}(#{args}) is not a valid command"
      end
  end
end

class WRF
  attr_reader :conf
  def initialize(conf,which_mpi)
    @conf = conf
    @rstatus = false
    @wrf = setup(which_mpi)
  end
  def setup(which_mpi)
    args = [conf.run_path,     # run directory
            conf.bin_path,     # executable directory
            [],     # input files 
            conf.tbl_path,     # path to misc. tables
            conf.wrf_namelist, # location of namelist.input
            {"-np" => 1}   ]    
    case which_mpi 
      when :mpi
        WRF_MPI_Run.new(*args)
      when :mpi_ib
        WRF_MPI_IB_Run.new(*args)
      when :mpi_eth
        WRF_MPI_Eth_Run.new(*args)
      end
  end
  def run
    @rstatus=@wrf.run
    self
  end
  
  def wrf_in=(arr)
    @wrf.wrf_in=arr.map {|f| File.expand_path(File.join(conf.pre_path,f)) }
  end


  def cleanup
    p "to clean or not to"
    @wrf.clean if @rstatus
    "not " if not @rstatus
  end

  def method_missing(name,*args)
    case name.to_s
      when /hostfile|run_cmd|run_opts|mpi_opts|wrf_in/
        @wrf.send(name, *args)
      else
        abort "#{name}(#{args}) is not a valid command"
      end
  end
end
