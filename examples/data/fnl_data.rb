class FNL_Data
 
  HR_TO_SEC=60*60 
  def self.fnames(s_utc,e_utc,lbc_upd_frq_in_hrs)
    start_time=Time.utc(*s_utc)
    end_time=Time.utc(*e_utc)
    fnames=[]
    while start_time <= end_time do
      yr=start_time.year
      mn="%02d" % start_time.mon
      dy="%02d" % start_time.day
      hr="%02d" % start_time.hour
      fnames << "#{yr}/fnl_#{yr}#{mn}#{dy}_#{hr}_00"
      start_time+= (lbc_upd_frq_in_hrs*HR_TO_SEC)
    end
    fnames
  end

end
