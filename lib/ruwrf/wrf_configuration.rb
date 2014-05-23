require 'yaml'
require 'pp'

class WRFConfiguration
  def initialize(fname)
    @inlist=YAML::load( File.open(fname))
  end

  def inlist
    @inlist
  end

  def sim_conditions
    inlist["simulation"]
  end

  def sim_dates
    inlist["dates"]
  end

  def sim_dirs
    inlist["directories"]
  end

  def wps_namelist
    sim_dirs["wps_namelist"]
  end

  def wrf_namelist
    sim_dirs["wrf_namelist"]
  end

  def wrf_nml4sst
    sim_dirs["wrf_nml4sst"]
  end

  def bin_path
    sim_dirs["executable"]
  end
  def pre_path
    sim_dirs["pre_process"]
  end
  def vtable
    sim_dirs["vtable"]
  end
  def lbc_path
    sim_dirs["lbc_dir"]
  end
  def lbc_files
    sim_dirs["lbc_list"]
  end
  def run_path
    sim_dirs["run"]
  end
  def tbl_path
    sim_dirs["misc_tables"]
  end

  def is_the_last_batch?
    sim_conditions["last_batch?"]
  end

  def is_a_restart?
    sim_conditions["ic_from_restart?"]
  end

  def lbc_upd_frq_in_hrs
    sim_conditions["lbc_upd_frq_in_hrs"]
  end

  def syr
    sim_dates["syr"]
  end

  def eyr
    sim_dates["eyr"]
  end

  def smo
    sim_dates["smo"]
  end

  def emo 
    sim_dates["emo"]
  end

  def sdy
    sim_dates["sdy"]
  end
  def edy 
    sim_dates["edy"]
  end

  def shr 
    sim_dates["shr"]
  end

  def ehr 
    sim_dates["ehr"]
  end

  def smi
    0
  end

  def emi
    0
  end

  def ssc
    0
  end

  def esc
    0
  end

  def s_utc
    [syr,smo,sdy,shr,smi,ssc]
  end

  def e_utc
    [eyr,emo,edy,ehr,emi,esc]
  end

  def stime
    Time.utc(*s_utc)
  end

  def etime
    Time.utc(*e_utc)
  end

  def duration
    ((etime-stime)/60).to_i
  end

  def dfi
    [stime-60*60,stime+30*60]
  end

  def spin4sst
    [stime,dfi[1]+10*60]
  end
end

module DFFI
  def dffi(nml,conf)
    df = nml[:dfi_control]
    df[:dfi_bckstop_year], df[:dfi_fwdstop_year] = conf.dfi.map {|d| d.year}
    df[:dfi_bckstop_month], df[:dfi_fwdstop_month] = conf.dfi.map {|d| d.mon}
    df[:dfi_bckstop_day], df[:dfi_fwdstop_day] = conf.dfi.map {|d| d.day}
    df[:dfi_bckstop_hour], df[:dfi_fwdstop_hour] = conf.dfi.map {|d| d.hour}
    df[:dfi_bckstop_minute], df[:dfi_fwdstop_minute] = conf.dfi.map {|d| d.min}
    df[:dfi_bckstop_second], df[:dfi_fwdstop_second] = conf.dfi.map {|d| d.sec}
    return(df)
  end
end

