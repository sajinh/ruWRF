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
mpi_opts      = {"-np" => 26}
wrf_in = ["./work/wrfinput_d01","./work/wrfbdy_d01"]

wrf = WRF_MPI_Run.new(run_dir, wrf_tbl, wrf_bin, wrf_in, nam_lst,mpi_opts)
wrf.hostfile = "./wrf_hostfile"
pp wrf.run_opts
pp wrf.run_cmd
#real.run_cmd="sudo /home/saji/InfiniBand/bin/mpirun"
pp wrf.run_cmd
status= wrf.run
p status
exit
pp real.clean if status
