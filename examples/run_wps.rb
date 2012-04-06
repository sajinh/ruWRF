my_home="/fs4/saji"
require "#{my_home}/ruWRF/lib/ruwrf"
require 'yaml'
require 'pp'

inlist=YAML::load( File.open('inlist.yml') )
sim_dirs  = inlist["directories"]

pre_dir       = sim_dirs["pre_process"]
wrf_bin       = sim_dirs["executable"]
vtable        = sim_dirs["vtable"]
nam_lst       = sim_dirs["wps_namelist"]
input_dir     = sim_dirs["lbc_data"]
input_files   = IO.readlines(sim_dirs["lbc_list"])

# Write location of data to input_files
input_files.map! {|f| File.join input_dir, f.chomp}
all_present   = input_files.all? {|f| File.exist? f}

abort "Some input files are not present; eXit" unless all_present
puts "Proceeding to pre_processing step"

mpi_opts={"-np" => 26}
pre= WRF_MPI_Pre.new(pre_dir, wrf_bin, input_files, vtable,  nam_lst, mpi_opts)
ung= WRF_Pre.new(pre_dir, wrf_bin, input_files, vtable,  nam_lst, opts={})
pre.hostfile="./wrf_hostfile"
pp pre.run_opts
pp pre.run_cmd
pp ung.run_cmd
pp pre.setup
#pp gstate=(pre.run_exe "geogrid")
pp ustate=(ung.run_exe "ungrib")
pp pre.clean
gstate=true
pp mstate=(pre.run_exe "metgrid") if gstate and ustate

