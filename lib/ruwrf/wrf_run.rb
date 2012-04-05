require File.join File.dirname(__FILE__), 'wrf_libs'
require 'fileutils'

class WRF_Run
  include WRF_Common
  attr_accessor :run_dir, :wrf_bin
  attr_accessor :nam_lst, :wrf_in
  attr_accessor :run_opts, :run_cmd
  attr_reader :wrf_tbl
  def initialize(run_dir, wrf_tbl, wrf_bin, wrf_in, nam_lst, opts={})
    @run_dir=File.expand_path run_dir
    @wrf_bin=File.expand_path wrf_bin
    @wrf_tbl=File.expand_path wrf_tbl
    @wrf_in=wrf_in.map {|f| File.expand_path f}
    @nam_lst=File.expand_path nam_lst
    @opts=opts
    @run_cmd=""
  end


  def def_opts
    {}
  end

  def run_opts
    def_opts.merge @opts
  end
 
  def cp_wrf_tables
    puts "Copying WRF Tables unless they are absent"
    Dir.glob(wrf_tbl+"/*").each do |fil|
     local_fil=File.join run_dir, File.basename(fil)
      FileUtils.cp(fil,run_dir) unless File.exist? local_fil
    end
  end

  def cp_input_data(data_in)
    local_copy=data_in.map {|d| File.join(run_dir,File.basename(d))}
    local_copy.each_with_index do |d,idx|
      if File.exists? d
        print "The file #{data_in[idx]} exists in WRF run directory"
        puts " : Not overwriting"
      else
        begin
          FileUtils.cp(data_in[idx],d)  unless File.exist? d
          puts "Copied #{data_in[idx]}"
        rescue
          abort "Exiting becoz the file \"#{data_in[idx]}\" is absent"
        end
      end
    end
  end

  def run_directives
    run_opts.to_a.join " "
  end

  def run
    FileUtils.mkdir run_dir unless File.exist? run_dir
    cp_input_data(wrf_in)
    cp_wrf_tables
    cp_namlst(@nam_lst,run_dir)
    mpi_opts = run_directives
    Dir.chdir(run_dir) do
      FileUtils.rm Dir.glob("rsl.*")
      system("#{run_cmd} #{mpi_opts} #{wrf_bin}/wrf.exe".strip)
    end
  end

  def clean
    Dir.chdir(run_dir) do 
      FileUtils.mv "rsl.out.0000", "timing.dat" if File.exist? "rsl.out.0000"
      FileUtils.rm Dir.glob("*.TBL")
      FileUtils.rm Dir.glob("*DATA*")
      FileUtils.rm Dir.glob("rsl.*")
    end
  end

end

class WRF_MPI_Run < WRF_Run

  include MPI_Run
  attr_writer :hostfile, :rankfile

  def initialize(a, b, c, d, e, f)
    super(a,b,c,d,e,f)
    @run_cmd="mpirun"
  end

end

class WRF_MPI_IB_Run < WRF_MPI_Run
  def def_opts
    { "--mca"=> "btl_openib_verbose 1 --mca btl ^tcp --bind-to-core",
      "-np" => 1}
  end
end

class WRF_MPI_Eth_Run < WRF_MPI_Run
  def def_opts
    { "--mca"=> "btl ^openib --mca btl_tcp_if_include eth0 ",
      "-np" => 1}
  end
end
