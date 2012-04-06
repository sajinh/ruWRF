myhome=ENV['HOME']
myhome2='/fs4/saji'
require "#{myhome2}/fortran-namelist/lib/nml.rb"

infil = "../namelists/namelist.wps.all_options"
opfil = "../namelists/namelist.wps.FNL_AAsia"

nml = NML_Reader.read infil

# delete group &mod_levs and &plotfmt

nml.delete(:mod_levs)
nml.delete(:plotfmt)

# delete unnecessary records from group &share
nml[:share].del :start_date, 
        :end_date, 
        :active_grid,
        :subgrid_ratio_x,
        :subgrid_ratio_y,
        :opt_output_from_geogrid_path,
        :debug_level


# delete unnecessary records from group &geogrid
nml[:geogrid].del :s_we, :s_sn, :ref_x, :ref_y

# delete unnecessary records from group &metgrid

nml[:metgrid].del :constants_name, :opt_output_from_metgrid_path,
        :process_only_bdy

# modify largely unchanging records in each group
# for the FNL AAsia experiment

g=nml[:geogrid]
g[:parent_id]= 1,1,1
g[:parent_grid_ratio]= 1,3,3
g[:i_parent_start]= 1,24,202
g[:j_parent_start]= 1,70,134
g[:e_we] = 378,751,214
g[:e_sn] = 220,214,214
g[:geog_data_res] = 'modis_30s+10m', 'modis_30s+2m', 'modis_30s+30s'
g[:dx],g[:dy]=54000,54000
g[:map_proj]='mercator'
g[:ref_lat],g[:ref_lon] = 0, 110
g[:geog_data_path] = "#{myhome}/WRF/share/geog"
g[:truelat1], g[:truelat2] = 0,0
g[:stand_lon] = 110
g[:opt_geogrid_tbl_path] = "#{myhome}/WRF/share/wrf/geogrid"


nml[:metgrid][:opt_metgrid_tbl_path]="#{myhome}/WRF/share/wrf/metgrid"
ofil = File.open(opfil,"w")
nml_writer = NML_Writer.new
nml_writer << nml
nml_writer >> ofil
ofil.close
