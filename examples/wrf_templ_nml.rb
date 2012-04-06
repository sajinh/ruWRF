myhome=ENV['HOME']
myhome2='/fs4/saji'
require "#{myhome}/fortran-namelist/lib/nml.rb"

infil = "../namelists/namelist.input.all_options"
opfil = "../namelists/namelist.input.FNL_AAsia"

nml = NML_Reader.read infil

# delete group &mod_levs and &plotfmt

nml.delete(:fdda)
nml.delete(:grib2)

# delete unnecessary records from group &share
nml[:time_control].del :run_days,
        :run_hours,
        :run_minutes,
        :run_seconds,        :auxinput4_inname,
        :auxinput4_interval,
        :io_form_auxinput4,
        :auxinput11_interval_s,
        :auxinput11_end_h,
        :output_diagnostics,
        :auxhist3_outname,
        :io_form_auxhist3,
        :auxhist3_interval,
        :frames_per_auxhist3


# modify largely unchanging records in each group
# for the FNL AAsia experiment

nml[:domains].del :eta_levels
g=nml[:domains]
  g[:parent_id]                = 1,1,1
  g[:parent_grid_ratio]        = 1,3,3
  g[:grid_id]                  = 1, 2, 3
  g[:i_parent_start]           = 1,24,202
  g[:j_parent_start]           = 1,70,134
  g[:parent_time_step_ratio]   = 1,3,3
  g[:feedback]                 = 0
  g[:max_dom]                  = 1
  g[:smooth_option]            = 0
  g[:e_we]                     = 378,751,214
  g[:e_sn]                     = 220,214,214
  g[:e_vert]                   = 51, 51, 51
  g[:p_top_requested]          = 1000
  g[:dx]                       = 54000, 18000, 18000
  g[:dy]                       =  54000, 18000, 18000
  g[:smooth_cg_topo]           = '.true.'
  g[:use_adaptive_time_step]   = '.true.'
  g[:step_to_output_time]      = '.true.'
  g[:target_cfl]               = 0.8
  g[:target_hcfl]              = 0.6
  g[:starting_time_step]       = 120
  g[:min_time_step]            = 120

nml[:physics].del :sst_update, :tmn_update, :sst_skin, :slope_rad,
                 :topo_shading, :shadlen, :sf_urban_physics
ph = nml[:physics]
  ph[:sf_sfclay_physics]       = 1
  ph[:sf_surface_physics]      = 2
  ph[:bl_pbl_physics]          = 1
  ph[:bldt]                    = 0
  ph[:mp_physics]              = 6
  ph[:ra_lw_physics]           = 3
  ph[:ra_sw_physics]           = 3
  ph[:radt]                    = 50
  ph[:levsiz]                  = 59
  ph[:paerlev]                 = 29
  ph[:cam_abs_dim1]            = 4
  ph[:cam_abs_dim2]            = 51
  ph[:cu_physics]              = 1
  ph[:cudt]                    = 10

nml[:dfi_control][:dfi_time_dim] = 1000

dy = nml[:dynamics]
  dy[:rk_ord] = 3
  dy[:time_step_sound] = 0
  dy[:gwd_opt] = 1

nml[:bdy_control][:spec_exp] = 0.33

ofil = File.open(opfil,"w")
nml_writer = NML_Writer.new
nml_writer.okeys=nml[:okeys]
nml_writer << nml
nml_writer >> ofil
ofil.close
