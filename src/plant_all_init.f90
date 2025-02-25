      subroutine plant_all_init
    
      use plant_module
      use plant_data_module
      use hru_module, only : hru, isol, ilu
      use hydrograph_module, only : sp_ob
      use maximum_data_module
            
      implicit none

      integer :: iihru = 0          !none   |hru number to send to plant_init
      integer :: ipl = 0
      integer :: iplt = 0
      integer :: ipl_bsn = 0
      integer :: num_plts_cur = 0   !none   |temporary counter for number of different plants in basin

      allocate (plts_bsn(db_mx%plantparm))
      allocate (bsn_crop_yld(db_mx%plantparm))
      allocate (bsn_crop_yld_aa(db_mx%plantparm))
      
      !!assign land use pointers for the hru
      !!allocate and initialize land use and management
      do iihru = 1, sp_ob%hru
        !!ihru, ilu and isol are in modparm
        ilu = hru(iihru)%dbs%land_use_mgt
        isol = hru(iihru)%dbs%soil
        !send 0 value in when initializing- 1 for updating to deallocate
        call plant_init (0, iihru)
      end do

      !! find all different plants in simulation for yield output
      do iihru = 1, sp_ob%hru
        do ipl = 1, pcom(iihru)%npl
          if (basin_plants == 0) then
            plts_bsn(1) = pcom(iihru)%pl(ipl)
            basin_plants = 1
          else
          num_plts_cur = basin_plants
          do iplt = 1, num_plts_cur
            if (pcom(iihru)%pl(ipl) == plts_bsn(iplt)) exit
            if (iplt == num_plts_cur) then
              plts_bsn(iplt+1) = pcom(iihru)%pl(ipl)
              basin_plants = basin_plants + 1
            end if
          end do
          end if
        end do
      end do

      !! zero basin crop yields and harvested areas
      do ipl_bsn = 1, basin_plants
        bsn_crop_yld(ipl_bsn) = bsn_crop_yld_z
        bsn_crop_yld_aa(ipl_bsn) = bsn_crop_yld_z
      end do

      do iihru = 1, sp_ob%hru
        do ipl = 1, pcom(iihru)%npl
          do ipl_bsn = 1, basin_plants
            if (pcom(iihru)%pl(ipl) == plts_bsn(ipl_bsn)) then
              pcom(iihru)%plcur(ipl)%bsn_num = ipl_bsn
              exit
            end if
          end do
        end do
      end do
      
      return
      
      end subroutine plant_all_init