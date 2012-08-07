require 'yaml'
require 'pp'
my_home="/fs4/saji"
require "#{my_home}/ruWRF/lib/ruwrf"

inlist=YAML::load( File.open('inlist.yml') )
sim_dirs  = inlist["directories"]
run_dir       = sim_dirs["run"]
wrf_tbl       = sim_dirs["misc_tables"]
wrf_bin       = sim_dirs["executable"]
pre_dir       = sim_dirs["pre_process"]
nam_lst       = sim_dirs["wrf_namelist"]
mpi_opts      = {"-np" => 56}

real = WRF_MPI_Real.new(run_dir, wrf_tbl, wrf_bin, pre_dir, nam_lst,mpi_opts)
real.hostfile = "./wrf_hostfile2"
pp real.run_opts
pp real.run_cmd
#real.run_cmd="sudo /home/saji/InfiniBand/bin/mpirun"
pp real.run_cmd
status= real.run
pp real.clean if status
