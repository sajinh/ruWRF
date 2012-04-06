require 'yaml'
require 'pp'
myhome=ENV['HOME']
myhome2='/fs4/saji'
require "#{myhome2}/fortran-namelist/lib/nml.rb"
require "#{myhome2}/ruWRF/lib/ruwrf.rb"
require './data/fnl_data'

infil = "../namelists/namelist.input.FNL_AAsia"
nml   = NML_Reader.read infil


inlist=YAML::load( File.open('inlist.yml') )
sim_conditions = inlist["simulation"]
sim_dates = inlist["dates"]
sim_dirs  = inlist["directories"]
opfil = sim_dirs["wrf_namelist"]

END_OF_SIMULATION= sim_conditions["last_batch?"]
RESTART=sim_conditions["ic_from_restart?"]
lbc_upd_frq_in_hrs = sim_conditions["lbc_upd_frq_in_hrs"]


syr, eyr = sim_dates["syr"], sim_dates["eyr"]
smo, emo = sim_dates["smo"], sim_dates["emo"]
sdy, edy = sim_dates["sdy"], sim_dates["edy"]
shr, ehr = sim_dates["shr"], sim_dates["ehr"]
smi,emi,ssc,esc=0,0,0,0

s_utc=[syr,smo,sdy,shr,smi,ssc]
e_utc=[eyr,emo,edy,ehr,emi,esc]

stime = Time.utc(*s_utc)
etime = Time.utc(*e_utc)
duration = ((etime-stime)/60).to_i
dfi = [stime-60*60,stime+30*60]

# Manipulate Namelist file to add right start and end dates
# of simulation

shar = nml[:time_control]
shar[:start_year], shar[:end_year] = syr, eyr
shar[:start_month], shar[:end_month] = smo, emo
shar[:start_day], shar[:end_day] = sdy, edy
shar[:start_hour], shar[:end_hour] = shr, ehr
shar[:start_minute], shar[:end_minute] = smi, emi
shar[:start_second], shar[:end_second] = ssc, esc
shar[:interval_seconds]=lbc_upd_frq_in_hrs*secs_per_hr
shar[:restart] = ".#{RESTART}." 
shar[:restart_interval] = duration

shar.del :no_colons, :nocolons

dm =  nml[:domains]
  dm[:max_dom] = 1
  dm[:time_step] = 120
  dm.del  :tile_sz_x,:tile_sz_y,:numtiles,:nproc_x,:nproc_y


nml[:physics][:num_land_cat] = 20
df = nml[:dfi_control]
  df[:dfi_bckstop_year], df[:dfi_fwdstop_year] = dfi.map {|d| d.year}
  df[:dfi_bckstop_month], df[:dfi_fwdstop_month] = dfi.map {|d| d.mon}
  df[:dfi_bckstop_day], df[:dfi_fwdstop_day] = dfi.map {|d| d.day}
  df[:dfi_bckstop_hour], df[:dfi_fwdstop_hour] = dfi.map {|d| d.hour}
  df[:dfi_bckstop_minute], df[:dfi_fwdstop_minute] = dfi.map {|d| d.min}
  df[:dfi_bckstop_second], df[:dfi_fwdstop_second] = dfi.map {|d| d.sec}

outfil = File.open(opfil,"w")
nml_writer = NML_Writer.new
nml_writer.okeys=nml[:okeys]
nml_writer << nml 
nml_writer >> outfil
nml_writer >> STDOUT
p opfil
outfil.close
