      subroutine soil_nutcarb_write(out_freq)

!!    ~ ~ ~ PURPOSE ~ ~ ~
!!    this subroutine writes HRU output to the output.hru file

!!    ~ ~ ~ INCOMING VARIABLES ~ ~ ~
!!    name          |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    gw_q(:)       |mm H2O        |groundwater contribution to streamflow from
!!                                 |HRU on current day
!!    hru_ha(:)     |ha            |area of HRU in hectares
!!    hru_km(:)     |km^2          |area of HRU in square kilometers
!!    ihru          |none          |HRU number
!!    rchrg(:)      |mm H2O        |amount of water recharging both aquifers on
!!                                 |current day in HRU
!!    surfq(:)      |mm H2O        |surface runoff generated on day in HRU
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ LOCAL DEFINITIONS ~ ~ ~
!!    name        |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    ii          |none          |counter
!!    j           |none          |HRU number
!!    sb          |none          |subbasin number
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ ~ ~ ~ END SPECIFICATIONS ~ ~ ~ ~ ~ ~

      use soil_module
      use organic_mineral_mass_module
      use hydrograph_module
      use calibration_data_module
      use carbon_module, only: org_flux_zero
      use basin_module
      
      implicit none
      
      character(len=1), intent(in) :: out_freq   ! Output freqency (d, m, y, a)
      integer :: ly = 0         !none        |counter
      real :: const = 0.        !none        |counter
      integer :: iihru = 0      !none        |counter
      integer :: j = 0          !none        |counter
      integer :: iob = 0
      character (len=6) :: freq_label

      select case(out_freq)
        case ("d")
          freq_label = "day"
        case ("m")
          freq_label = "mon"
        case ("y")
          freq_label = "year"
        case ("a")
          freq_label = "av_ann"
      end select
           
      !! basin output - zero daily basin outputs before summing
      bsn_org_soil = soil_org_z
      bsn_org_pl = soil_org_z
      bsn_org_rsd = soil_org_z
        
      !! sum the output for the entire soil profile
      do j = 1, sp_ob%hru
        iob = sp_ob1%hru + j - 1
        soil1(j)%tot_org = soil_org_z
        soil_prof_hact = soil_org_z
        soil_prof_hsta = soil_org_z
        soil_prof_rsd = soil_org_z
        soil_prof_str = soil_org_z
        soil_prof_lig = soil_org_z
        soil_prof_meta = soil_org_z
        soil_prof_srsd = soil_org_z
        soil_prof_sstr = soil_org_z
        soil_prof_slig = soil_org_z
        soil_prof_smeta = soil_org_z
        soil_prof_man = soil_org_z
        soil_prof_hs = soil_org_z
        soil_prof_hp = soil_org_z
        soil_prof_microb = soil_org_z
        soil_prof_water = soil_org_z
        do ly = 1, soil(j)%nly
          soil_prof_hact = soil_prof_hact + soil1(j)%hact(ly)
          soil_prof_hsta = soil_prof_hsta + soil1(j)%hsta(ly)
          if (ly == 1) then
            soil_prof_srsd = soil_prof_srsd + soil1(j)%rsd(ly)
            soil_prof_smeta = soil_prof_smeta + soil1(j)%meta(ly)
            soil_prof_sstr = soil_prof_sstr + soil1(j)%str(ly)
            soil_prof_slig = soil_prof_slig + soil1(j)%lig(ly)
          else
            soil_prof_rsd = soil_prof_rsd + soil1(j)%rsd(ly)
            soil_prof_meta = soil_prof_meta + soil1(j)%meta(ly)
            soil_prof_str = soil_prof_str + soil1(j)%str(ly)
            soil_prof_lig = soil_prof_lig + soil1(j)%lig(ly)
          end if
          soil_prof_man = soil_prof_man + soil1(j)%man(ly)
          soil_prof_hs = soil_prof_hs + soil1(j)%hs(ly)
          soil_prof_hp = soil_prof_hp + soil1(j)%hp(ly)
          soil_prof_microb = soil_prof_microb + soil1(j)%microb(ly)
          soil_prof_water = soil_prof_water + soil1(j)%water(ly)
        end do
        soil1(j)%tot_org = soil_prof_hs + soil_prof_hp + soil_prof_microb + soil_prof_meta
        
        !write all organic carbon for the plant community file = "hru_plc_stat.txt"
        write (4560,*) freq_label, time%day, time%mo, time%day_mo, time%yrc, j, ob(iob)%gis_id, ob(iob)%name, &
            pl_mass(j)%tot_com%c, pl_mass(j)%ab_gr_com%c, pl_mass(j)%leaf_com%c,                  &
            pl_mass(j)%stem_com%c, pl_mass(j)%seed_com%c, pl_mass(j)%root_com%c
        ! file = "hru_plc_stat.csv"
        if (pco%csvout == "y") then
            write (4563,'(*(G0.7,:,","))') freq_label, time%day, time%mo, time%day_mo, time%yrc, j, ob(iob)%gis_id, ob(iob)%name, &
            pl_mass(j)%tot_com%c, pl_mass(j)%ab_gr_com%c, pl_mass(j)%leaf_com%c,                  &
            pl_mass(j)%stem_com%c, pl_mass(j)%seed_com%c, pl_mass(j)%root_com%c
        end if
          
        !write all organic carbon for the residue file = "hru_rsdc_stat.txt"
        write (4561,*) freq_label, time%day, time%mo, time%day_mo, time%yrc, j, ob(iob)%gis_id, ob(iob)%name, &
            soil_prof_srsd%c, soil_prof_smeta%c, soil_prof_sstr%c, soil_prof_slig%c,              &
            soil_prof_rsd%c, soil_prof_meta%c, soil_prof_str%c, soil_prof_lig%c
        ! file = "hru_rsdc_stat.csv"
        if (pco%csvout == "y") then
          write (4564,'(*(G0.7,:,","))') freq_label, time%day, time%mo, time%day_mo, time%yrc, j, ob(iob)%gis_id, ob(iob)%name, &
            soil_prof_srsd%c, soil_prof_smeta%c, soil_prof_sstr%c, soil_prof_slig%c,              &
            soil_prof_rsd%c, soil_prof_meta%c, soil_prof_str%c, soil_prof_lig%c
        end if

        !write all organic carbon for the soil profile, file = "hru_soilc_stat.txt"
        write (4562,*) freq_label, time%day, time%mo, time%day_mo, time%yrc, j, ob(iob)%gis_id, ob(iob)%name, &
            soil1(j)%tot_org%c, soil_prof_hs%c, soil_prof_hp%c, soil_prof_microb%c,               &
            soil_prof_meta%c, soil_prof_str%c, soil_prof_lig%c, soil_prof_man%c
        !file = "hru_soilc_stat.csv"
        if (pco%csvout == "y") then
          write (4565,'(*(G0.7,:,","))') freq_label, time%day, time%mo, time%day_mo, time%yrc, j, ob(iob)%gis_id, ob(iob)%name, &
            soil1(j)%tot_org%c, soil_prof_hs%c, soil_prof_hp%c, soil_prof_microb%c,               &
            soil_prof_meta%c, soil_prof_str%c, soil_prof_lig%c, soil_prof_man%c
        end if
      
        !write organic flux pools for the soil profile file = "hru_cflux_stat.txt"
        if (bsn_cc%cswat == 2) then
          write (4567,*) freq_label, time%day, time%mo, time%day_mo, time%yrc, j, ob(iob)%gis_id, ob(iob)%name, &
                        soil1(j)%org_flx_cum_tot 
          !file = "hru_cflux_stat.csv"
          if (pco%csvout == "y") then
            write (4568,'(*(G0.7,:,","))') freq_label, time%day, time%mo, time%day_mo, time%yrc, j, ob(iob)%gis_id, ob(iob)%name, &
                          soil1(j)%org_flx_cum_tot 
          endif 
        end if

        !write soil carb mass balance for the soil profile file = "hru_soilcarb_mb_stat.txt"
        if (bsn_cc%cswat == 2) then
          write (4570,*) freq_label, time%day, time%mo, time%day_mo, time%yrc, j, ob(iob)%gis_id, ob(iob)%name, &
                        soil1(j)%tot_org%c, soil_prof_hs%c, soil_prof_hp%c, soil_prof_microb%c,               &
                        soil_prof_meta%c, soil_prof_str%c, soil_prof_lig%c, soil_prof_man%c,                  &
                        soil1(j)%org_flx_cum_tot 
          !file = "hru_soilcarb_mb_stat.csv"
          if (pco%csvout == "y") then
            write (4571,'(*(G0.7,:,","))') freq_label, time%day, time%mo, time%day_mo, time%yrc, j, ob(iob)%gis_id, ob(iob)%name, &
                        soil1(j)%tot_org%c, soil_prof_hs%c, soil_prof_hp%c, soil_prof_microb%c,               &
                        soil_prof_meta%c, soil_prof_str%c, soil_prof_lig%c, soil_prof_man%c,                  &
                        soil1(j)%org_flx_cum_tot 
          endif 
        end if

        ! Set the org_flux pools to zero if at the end of the calendar year
        if (bsn_cc%cswat == 2) then
          if (out_freq == "y") then
            soil1(j)%org_flx_cum_tot = org_flux_zero
            do ly = 1, soil(j)%nly
              soil1(j)%org_flx_cum_lr(ly) = org_flux_zero
            end do
          end if
        end if
      end do    !! hru loop
      
      !! summing hru output for the basin
      do j = 1, sp_ob%hru
        iihru = lsu_elem(j)%obtypno
        if (lsu_elem(iihru)%bsn_frac > 1.e-12) then
          const = lsu_elem(iihru)%bsn_frac
          if (lsu_elem(iihru)%obtyp == "hru") then
            bsn_org_soil = bsn_org_soil + const * soil1(iihru)%tot_org
            bsn_org_pl = bsn_org_pl + const * pl_mass(iihru)%tot_com
            bsn_org_rsd = bsn_org_rsd + const * soil1(iihru)%rsd(1)
            bsn_mn = bsn_mn + const * soil1(iihru)%tot_mn
            bsn_mp = bsn_mp + const * soil1(iihru)%tot_mp
          end if
        end if
      end do
              
      !! write all carbon, organic n and p, and mineral n and p for the soil profile, plants, and residue
      write (4566,*) time%day, time%yrc, ' basin ', bsn_org_soil%c, bsn_org_pl%c, bsn_org_rsd%c
          
      return

      end subroutine soil_nutcarb_write