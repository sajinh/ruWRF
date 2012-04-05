require File.join File.dirname(__FILE__), 'wrf_libs'
require File.join File.dirname(__FILE__), '..', 'namelist', 'wrf_date'
require File.join File.dirname(__FILE__), '..', 'namelist', 'builder'
require 'fileutils'

class NameList
  include WRF_Common

  def initialize(start_time_utc,end_time_utc,
                   lbc_update_freq_in_hrs,template_dir, out_dir,opts={})
    @stime=start_time_utc
    @etime=end_time_utc
    @lbc_updates=lbc_update_freq_in_hrs
    @opts=default_opts.merge opts
    @template_dir=File.expand_path template_dir
    @out_dir=File.expand_path out_dir
  end

  def wps_template
    File.join @template_dir, "namelist.wps.template"
  end

  def wrf_template
    File.join @template_dir, "namelist.input.template"
  end

  def default_opts
    {:restart => false,
     :max_dom => 1}
  end

  def write_out
    wrf_date = WrfDate2.new(@stime,@etime,@etime,@lbc_updates)
    wps_namelist = Builder.new(wps_template,wrf_date,@out_dir,@opts)
    wrf_namelist = Builder.new(wrf_template,wrf_date,@out_dir,@opts)
    wps_namelist.write_out
    wrf_namelist.write_out
  end

end
