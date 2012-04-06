require 'yaml'
require 'pp'
myhome=ENV['HOME']
myhome2='/fs4/saji'
require "#{myhome2}/fortran-namelist/lib/nml.rb"
require "#{myhome2}/ruWRF/lib/ruwrf.rb"
require './data/fnl_data'

infil = "../namelists/namelist.wps.FNL_AAsia"
opfil = "./namelist.wps"
nml   = NML_Reader.read infil


inlist=YAML::load( File.open('inlist.yml') )
sim_conditions = inlist["simulation"]
sim_dates = inlist["dates"]
sim_dirs  = inlist["directories"]

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

# Write list of input data files
fnames=FNL_Data.fnames(s_utc,e_utc,lbc_upd_frq_in_hrs)
out_fil=sim_dirs["lbc_list"]
File.open(out_fil,"w") {|f| f.puts fnames}

# Manipulate Namelist file to add right start and end dates
# of simulation

shar = nml[:share]
shar[:start_year], shar[:end_year] = syr, eyr
shar[:start_month], shar[:end_month] = smo, emo
shar[:start_day], shar[:end_day] = sdy, edy
shar[:start_hour], shar[:end_hour] = shr, ehr
shar[:start_minute], shar[:end_minute] = smi, emi
shar[:start_second], shar[:end_second] = ssc, esc
shar[:max_dom]=1
shar[:interval_seconds]=lbc_upd_frq_in_hrs*secs_per_hr

outfil = File.open(opfil,"w")
nml_writer = NML_Writer.new
nml_writer.okeys=nml[:okeys]
nml_writer << nml 
nml_writer >> outfil
outfil.close
