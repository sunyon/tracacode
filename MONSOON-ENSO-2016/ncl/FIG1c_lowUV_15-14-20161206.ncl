;*************************************************************
;Aim: draw OLR annually ltm trend 
;Mission:
;   1. Read data
;   2. Post-post process
;     2.1 take the trend 
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-05-03
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN
;   2015-05-03  Change to caculate season trend 
;   2015-07-09  Change to caculate OLR
;   2015-07-09  Change to fit composite
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------U
;	var2--------------V
;================================================
;global variables
    ;Define parameters
    g_data_path1 = "/Users/zhenningli/data/obv/NCEP-DOE/monthly/uwnd.10m.mon.mean.nc"
    g_data_path2 = "/Users/zhenningli/data/obv/NCEP-DOE/monthly/vwnd.10m.mon.mean.nc"
    g_data_path3 = "/Users/zhenningli/data/obv/PRECT/cmap.precip.mon.nc"
    g_latS=-45.
    g_latN=45.
    g_lonW=30.
    g_lonE=220.
    
    ;Smaller Region
    g_latS=-20.
    g_latN=20.
    g_lonW=100.
    g_lonE=200.
    
    ; create an array of desired pressure levels:

        
    g_font = 0.03

    g_strt_mon = 197901 
    g_lst_mon = 201512
    ; long events larger than 10 months, develop
    ;g_sp_events = (/198201,198601,199101,199701/)
    g_sp_events = (/201501/)
    ; short events with 10 months, develop
    ;g_su_events = (/197901,199401,200201,200401,200601,200901/)
    g_su_events = (/201401/)

    ; long events larger than 10 months, decay
    ;g_sp_events = (/198301,198701,199201,199801/)
    ; short events with 10 months, decay
    ;g_su_events = (/198001,199501,200301,200501,200701,201001/)
    n_sp_events= dimsizes(g_sp_events)
    n_su_events= dimsizes(g_su_events)
    g_fig_name    =   "../fig/FIG1ac_"+g_strt_mon+"-"+g_lst_mon+"_10mUV_LE-SE-cmp-2015"
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    
    g_fig_title     = "2015-2014 Pr, UV10m & Vorticity"

;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path1
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
	var1  =short2flt(ctrl_in1->uwnd(istrt:ilast,0,:,:))			; p for unify the var name

    ctrl_file2   = g_data_path2
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
	var2  =short2flt(ctrl_in2->vwnd(istrt:ilast,0,:,:))			; p for unify the var name

; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================

    var1=month_to_season12(var1)
    var2=month_to_season12(var2)

    smp_sp_var1 = var1(0:12*n_sp_events-1,:,:)
    do ii=0,n_sp_events-1
        i_evstrt= ind(yyyymm .eq. g_sp_events(ii)) - istrt
        print(i_evstrt)
        smp_sp_var1(ii*12:ii*12+11,:,:) = var1(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_sp_var1_avg = clmMonTLL(smp_sp_var1)

    smp_su_var1 = var1(0:12*n_su_events-1,:,:)
    do ii=0,n_su_events-1
        i_evstrt= ind(yyyymm .eq. g_su_events(ii)) - istrt
        print(i_evstrt)
        smp_su_var1(ii*12:ii*12+11,:,:) = var1(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_su_var1_avg = clmMonTLL(smp_su_var1)
 
    smp_sp_var2 = var2(0:12*n_sp_events-1,:,:)
    do ii=0,n_sp_events-1
        i_evstrt= ind(yyyymm .eq. g_sp_events(ii)) - istrt
        print(i_evstrt)
        smp_sp_var2(ii*12:ii*12+11,:,:) = var2(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_sp_var2_avg = clmMonTLL(smp_sp_var2)

    smp_su_var2 = var2(0:12*n_su_events-1,:,:)
    do ii=0,n_su_events-1
        i_evstrt= ind(yyyymm .eq. g_su_events(ii)) - istrt
        print(i_evstrt)
        smp_su_var2(ii*12:ii*12+11,:,:) = var2(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_su_var2_avg = clmMonTLL(smp_su_var2)

        ; Var3

    ctrl_file3   = g_data_path3
	ctrl_in3     = addfile (ctrl_file3, "r")   ; note the "s" of addfile
	time_hist1    = ctrl_in3->time
    yyyymm1  = cd_calendar(time_hist1,-1)
    istrt   = ind(yyyymm1 .eq. g_strt_mon)
    ilast   = ind(yyyymm1 .eq. g_lst_mon)
	var3  =ctrl_in3->precip(istrt:ilast,:,:)			; p for unify the var name
    
    var3=month_to_season12(var3)
    smp_sp_var3 = var3(0:12*n_sp_events-1,:,:)
    do ii=0,n_sp_events-1
        i_evstrt= ind(yyyymm .eq. g_sp_events(ii)) - istrt
        print(i_evstrt)
        smp_sp_var3(ii*12:ii*12+11,:,:) = var3(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_sp_var3_avg = clmMonTLL(smp_sp_var3)

    smp_su_var3 = var3(0:12*n_su_events-1,:,:)
    do ii=0,n_su_events-1
        i_evstrt= ind(yyyymm .eq. g_su_events(ii)) - istrt
        print(i_evstrt)
        smp_su_var3(ii*12:ii*12+11,:,:) = var3(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_su_var3_avg = clmMonTLL(smp_su_var3)
    
    cmp_sp_var1_var = cmp_sp_var1_avg
    cmp_su_var1_var = cmp_su_var1_avg
    cmp_sp_var2_var = cmp_sp_var2_avg
    cmp_su_var2_var = cmp_su_var2_avg
    cmp_sp_var3_var = cmp_sp_var3_avg
    cmp_su_var3_var = cmp_su_var3_avg
    do ii = 0,11 
        cmp_sp_var1_var(ii,:,:) = dim_variance_n(smp_sp_var1(ii::12,:,:),0)
        cmp_su_var1_var(ii,:,:) = dim_variance_n(smp_su_var1(ii::12,:,:),0)
        cmp_sp_var2_var(ii,:,:) = dim_variance_n(smp_sp_var2(ii::12,:,:),0)
        cmp_su_var2_var(ii,:,:) = dim_variance_n(smp_su_var2(ii::12,:,:),0)
        cmp_sp_var3_var(ii,:,:) = dim_variance_n(smp_sp_var3(ii::12,:,:),0)
        cmp_su_var3_var(ii,:,:) = dim_variance_n(smp_su_var3(ii::12,:,:),0)
    end do
    cmp_var1 = cmp_sp_var1_avg
    cmp_var1 = cmp_sp_var1_avg - cmp_su_var1_avg
    cmp_var2 = cmp_sp_var2_avg
    cmp_var2 = cmp_sp_var2_avg - cmp_su_var2_avg
    cmp_var3 = cmp_sp_var3_avg
    cmp_var3 = cmp_sp_var3_avg - cmp_su_var3_avg

    cmp_vr    = uv2vrF_Wrap (cmp_var1,cmp_var2)         ; u,v ==> vorticity (rel)
    ;--------------------------------
    ;--------Sig Test----------------
    ;--------------------------------
    diff_speed = cmp_var1
    diff_speed = sqrt(cmp_var1*cmp_var1 + cmp_var2*cmp_var2)
    cmp_var1@_FillValue= -999
    cmp_var1 = where(diff_speed .gt. 1.5, cmp_var1, cmp_var1@_FillValue)


    siglvl = 0.1                       ; critical sig lvl for r

    iflag= False                        ; population variance similar
    diff_cmp_var1_sig = cmp_var1
    diff_cmp_var2_sig = cmp_var2
    diff_cmp_var3_sig = cmp_var3
    do ii = 0,11
        prob1 = ttest(cmp_sp_var1_avg(ii,:,:),cmp_sp_var1_var(ii,:,:),n_sp_events, cmp_su_var1_avg(ii,:,:), cmp_su_var1_var(ii,:,:), n_su_events, iflag, False) 
        prob2 = ttest(cmp_sp_var2_avg(ii,:,:),cmp_sp_var2_var(ii,:,:),n_sp_events, cmp_su_var2_avg(ii,:,:), cmp_su_var2_var(ii,:,:), n_su_events, iflag, False) 
        prob3 = ttest(cmp_sp_var3_avg(ii,:,:),cmp_sp_var3_var(ii,:,:),n_sp_events, cmp_su_var3_avg(ii,:,:), cmp_su_var3_var(ii,:,:), n_su_events, iflag, False) 
        diff_cmp_var3_sig(ii,:,:) = mask(diff_cmp_var3_sig(ii,:,:), prob3 .lt. siglvl,True)
        diff_cmp_var1_sig= (/mask(diff_cmp_var1_sig,(prob1 .lt. siglvl) .or. (prob2 .lt. siglvl),True)/)    
    end do

    wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file

    
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/6/),graphic)
  plot_cn_pos = new((/6/),graphic)
  plot_cn_neg = new((/6/),graphic)
  plot_sig = new((/6/),graphic)
  plot_V = new((/6/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
 gsn_define_colormap(wks,"MPL_bwr")
;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



;  i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
;  j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)
    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        =  -10e-6          ; set min contour level
    res@cnMaxLevelValF        =  10e-6          ; set max contour level
    res@cnLevelSpacingF       =  10e-7          ; set contour interval
;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
  ;res@gsnSpreadColorStart  = 2               ; start at color 17
  ;res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1

  res@mpFillOn   = True     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  res@mpFillDrawOrder="PostDraw"
  res@mpCenterLonF = 180.
  res@mpMaxLatF  = g_latN
  res@mpMinLatF  = g_latS
  res@mpMaxLonF  = g_lonE
  res@mpMinLonF  = g_lonW

;  res@mpShapeMode = "FreeAspect" 

;  res@vpWidthF = 0.8
;  res@vpHeightF = 0.6

;  res@tmXBMajorOutwardLengthF = -0.
;  res@tmYLMajorOutwardLengthF = -0.
;  res@tmYRMajorOutwardLengthF = -0.
  
;  res@tmXBMinorOutwardLengthF = -0.
;  res@tmYLMinorOutwardLengthF = -0.
;  res@tmYRMinorOutwardLengthF = -0.
    
     ; now change the size of the tickmark labels
  res@tmXBTickSpacingF = 30
  res@tmYLTickSpacingF = 15
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =


;-----------------------------------------------------------------------------
    res3                  = True       ; use plot options
    res3@cnFillOn         = False;True       ; Fill contours
    res3@cnLinesOn        = True      ; turn off contour lines
    ;for tp masking
    res3@gsnFrame         = False
    res3@gsnDraw  = False
    res3@cnLineLabelsOn   = False      ; turn off contour line labels
    res3@cnLineThicknessF = 2 
    res3@cnInfoLabelOn = False


    res3@cnLevelSelectionMode="ExplicitLevels"
    res3@cnLevels = (/1.5,2.0,3.0,4.0/)
    res3@cnLineColor      = "Blue"
    res3@gsnLeftString      = " "
    res3@gsnRightString      = " "

    do i = 0,2
        cmpvarsmoth=smth9_Wrap(cmp_var3(i+2,:,:),0.5,0.25, True)
        plot_cn_pos(i) = gsn_csm_contour(wks,cmpvarsmoth,res3) ; create a default plot
    end do
    
    res3@cnLevels = -res3@cnLevels
    res3@cnLineColor      = "Red"
    res3@cnLineDashPattern      = 1
    do i = 0,2
        cmpvarsmoth=smth9_Wrap(cmp_var3(i+2,:,:),0.5,0.25, True)
        plot_cn_neg(i) = gsn_csm_contour(wks,cmpvarsmoth,res3) ; create a default plot
    end do


;-------------------------------------------------
;-----------------------------------------------------
  res4                  = True       ; use plot options
  res4@cnFillOn         = True       ; Fill contours
  res4@cnLinesOn        = False;True      ; turn off contour lines
  res4@gsnFrame         = False
  res4@gsnDraw  = False
  res4@cnLineLabelsOn   = False      ; turn off contour line labels
  res4@cnLineThicknessF = 2
  res4@cnLineColor      = "black"
  res4@cnInfoLabelOn = False
  res4@cnMonoFillPattern    = True;False
  res4@cnFillPattern = 3 
  res4@cnMonoFillScale = True
  res4@cnFillScaleF = 0.6 
  res4@cnMonoFillColor = True
  res4@cnFillColor  =  "black"
  res4@cnFillDotSizeF = 0.0025
 
  res4@lbLabelBarOn = False;True   ; turn off the label bar
 
;  res4@cnLevelSelectionMode="ExplicitLevels"
;  res4@cnLevels = (/3000,1000/)
  res4@gsnLeftString      = " "
  res4@gsnRightString      = " "
 
;-----------------------------------------------------------------------------
     ;-----------------------------------------------------------------------------
       ;-------Set for the vector plot------
    vcres = True
    vcres@gsnDraw          = False           ; don't draw
    vcres@gsnFrame         = False           ; don't advance frame
    vcres@gsnRightString   = " "             ; turn off right string
    vcres@gsnLeftString    = " "             ; turn off left string
    vcres@gsnCenterString    = " "

    vcres@vcRefAnnoOn      = True
    vcres@vcRefAnnoOrthogonalPosF = -1             ; move ref vector up
    vcres@vcRefMagnitudeF         = 2.0             ; define vector ref mag
    vcres@vcRefLengthF            = 0.045            ; define length of vec ref
    vcres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.03
    vcres@vcRefAnnoString1  = "2 m/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.015
    vcres@vcLineArrowThicknessF     = 2    ;thickness of vector

    vcres@vcLineArrowHeadMinSizeF   = 0.015
    vcres@vcLineArrowHeadMaxSizeF   = 0.015       
do i = 0,2
    res@gsnLeftString = g_fig_rank(i)
    res@gsnCenterString = g_fig_title
    res@gsnRightString = ""

    cmpvrsmoth=smth9_Wrap(cmp_vr(i+2,:,:),0.5,0.25, True)
    plot(i) = gsn_csm_contour_map_ce(wks,cmpvrsmoth,res)

    plot_sig(i) = gsn_csm_contour(wks,diff_cmp_var3_sig(i+2,:,:),res4)  ; Create shaded contours
    plot_V(i) = gsn_csm_vector(wks,cmp_var1(i+2,:,:),cmp_var2(i+2,:,:),vcres)
    overlay(plot(i),plot_V(i))
   ; overlay(plot(i),plot_sig(i))
    overlay(plot(i),plot_cn_neg(i))
    overlay(plot(i),plot_cn_pos(i))
end do
  draw(plot(1))
  frame(wks)

 end 