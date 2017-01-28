;*****************************************************
;Missions:
;   1. Read ggas data of RCP4.5 forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Monthly Timeseries of CO2
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;================================================
;Variables List:
;	var1--------------CO2
;	var2--------------CH4
;	var3--------------N2O
;	var4--------------f11
;	var5--------------f12
;================================================



begin
    data_file_name1="/home/yangsong3/data-model/CESM_CTRL/B2000_F09G16_CAM5PM_CTRL/pro/"
    data_file_name2="/home/yangsong3/data-model/L_Zealot/MONSOON-ENSO-2016/esmpost/"
    g_fig_name="../fig/FIG3_model"
    g_fig_title="ESM-CTRL Pr, UV10m & Vorticity"
    g_font =0.025
    g_fig_rank=(/"(a)"/)
    ;one month rightward shift
    yrstrt1  = 26102
    yrlast1  = 36301
    yrstrt2  = 26102
    yrlast2  = 26301 

    ;Smaller Region
    g_latS=-20.
    g_latN=20.
    g_lonW=100.
    g_lonE=200.
;---------------Read data-------------------
    ctrl_in1 = addfile(data_file_name1+"B2000_f09_CAM5PM_spin-up.cam.h0.U.261-262.nc","r")
    ctrl_var1 = ctrl_in1->U(2:4,0,:,:)
    
    ctrl_in1 = addfile(data_file_name1+"B2000_f09_CAM5PM_spin-up.cam.h0.V.261-262.nc","r")
    ctrl_var2 = ctrl_in1->V(2:4,0,:,:)    
    
    ctrl_in1 = addfile(data_file_name1+"B2000_f09_CAM5PM_spin-up.cam.h0.PRECC.261-262.nc","r")
    ctrl_var3 = ctrl_in1->PRECC(2:4,:,:)    
    
    ctrl_in1 = addfile(data_file_name1+"B2000_f09_CAM5PM_spin-up.cam.h0.PRECL.261-262.nc","r")
    ctrl_var4 = ctrl_in1->PRECL(2:4,:,:)
    ctrl_var3 = (ctrl_var3+ctrl_var4)*86400*1000

    all_file=systemfunc("ls "+data_file_name2+"*ESMt261_[1-9].cam.h0.U.*")
    exp_in = addfiles(all_file,"r")
    ListSetType (exp_in, "join")
    exp_var1 = exp_in[:]->U(:,2:4,{1000},:,:)

    all_file=systemfunc("ls "+data_file_name2+"*ESMt261_[1-9].cam.h0.V.*")
    exp_in = addfiles(all_file,"r")
    ListSetType (exp_in, "join")
    exp_var2 = exp_in[:]->V(:,2:4,{1000},:,:)

    all_file=systemfunc("ls "+data_file_name2+"*ESMt261_[1-9].cam.h0.PRECC.*")
    exp_in = addfiles(all_file,"r")
    ListSetType (exp_in, "join")
    exp_var3 = exp_in[:]->PRECC(:,2:4,:,:)

    all_file=systemfunc("ls "+data_file_name2+"*ESMt261_[1-9].cam.h0.PRECL.*")
    exp_in = addfiles(all_file,"r")
    ListSetType (exp_in, "join")
    exp_var4 = exp_in[:]->PRECL(:,2:4,:,:)
    exp_var3 = (exp_var3+exp_var4)*86400*1000

;--------------Proprocessing-----------
    ctrl_var1_ssn=dim_avg_n_Wrap(ctrl_var1,0)
    ctrl_var2_ssn=dim_avg_n_Wrap(ctrl_var2,0)
    ctrl_var3_ssn=dim_avg_n_Wrap(ctrl_var3,0)
   
    exp_var1_ssn=dim_avg_n_Wrap(exp_var1,1)
    exp_var2_ssn=dim_avg_n_Wrap(exp_var2,1)
    exp_var3_ssn=dim_avg_n_Wrap(exp_var3,1)

    exp_var1_var=dim_variance_n_Wrap(exp_var1_ssn,0)
    exp_var2_var=dim_variance_n_Wrap(exp_var2_ssn,0)
    exp_var3_var=dim_variance_n_Wrap(exp_var3_ssn,0)

    exp_var1_ssnmean=dim_avg_n_Wrap(exp_var1_ssn,0)
    exp_var2_ssnmean=dim_avg_n_Wrap(exp_var2_ssn,0)
    exp_var3_ssnmean=dim_avg_n_Wrap(exp_var3_ssn,0)

    diff_var1 = ctrl_var1_ssn
    diff_var2 = ctrl_var2_ssn
    diff_var3 = ctrl_var3_ssn

    diff_var1 = exp_var1_ssnmean - ctrl_var1_ssn
    diff_var2 = exp_var2_ssnmean - ctrl_var2_ssn
    diff_var3 = exp_var3_ssnmean - ctrl_var3_ssn

    cmp_vr    = uv2vrF_Wrap (diff_var1,diff_var2)         ; u,v ==> vorticity (rel)
    ;--------------------------------
    ;--------Sig Test----------------
    ;--------------------------------
    diff_speed = diff_var1
    diff_speed = sqrt(diff_var1*diff_var1 + diff_var2*diff_var2)
    diff_var1@_FillValue= -999
    diff_var1 = where(diff_speed .gt. 1.0, diff_var1, diff_var1@_FillValue)


    siglvl = 0.1                       ; critical sig lvl for r

    iflag= False                        ; population variance similar
    diff_var1_sig = diff_var1
    diff_var2_sig = diff_var2
    diff_var3_sig = diff_var3

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
    res@cnMinLevelValF        =  -5e-6          ; set min contour level
    res@cnMaxLevelValF        =  5e-6          ; set max contour level
    res@cnLevelSpacingF       =  5e-7          ; set contour interval
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
    res3@cnLevels = (/1.0,1.5,2.0,3.0/)
    res3@cnLineColor      = "Blue"
    res3@gsnLeftString      = " "
    res3@gsnRightString      = " "

    do i = 0,2
        cmpvarsmoth=smth9_Wrap(diff_var3,0.5,0.25, True)
        plot_cn_pos(i) = gsn_csm_contour(wks,cmpvarsmoth,res3) ; create a default plot
    end do
    
    res3@cnLevels = -res3@cnLevels
    res3@cnLineColor      = "Red"
    res3@cnLineDashPattern      = 1
    do i = 0,2
        cmpvarsmoth=smth9_Wrap(diff_var3,0.5,0.25, True)
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
do i = 0,0
    res@gsnLeftString = g_fig_rank(i)
    res@gsnCenterString = g_fig_title
    res@gsnRightString = ""

    cmpvrsmoth=smth9_Wrap(cmp_vr,0.5,0.25, True)
    plot(i) = gsn_csm_contour_map_ce(wks,cmpvrsmoth,res)

    plot_V(i) = gsn_csm_vector(wks,diff_var1,diff_var2,vcres)
    overlay(plot(i),plot_V(i))
    overlay(plot(i),plot_cn_neg(i))
    overlay(plot(i),plot_cn_pos(i))
end do
  draw(plot(0))
  frame(wks)





end



