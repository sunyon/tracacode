;*************************************************************
;Aim: For draw TS (total prec water) diff with sig test
;
;Mission:
;   1. Read data from post model datasets
;   2. Post-post process to deserved results 
;   3. Significance test
;   4. Draw the TS and overlap them
;                       Zhenning Li
;                       2014-11-07
;Last Edited:
;   2014-11-07  Create
;   2015-06-13  Modified to fit HEAT_MON
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------TS
;================================================
;global variables
    g_pver = 26
    g_res  = "f19"
    ;Define parameters
    g_data_path = "../data/model/pro/" 
    g_ctrl_case = "B2000_F19G16_CAM4_CTRL"
    g_sen_cases = (/"HEAT_SCS_MAM-2015"/)

    latS=-90.
    latN=90.
    lonW=0.
    lonE=360.
; create an array of desired pressure levels:
	g_season      =   "JJA"
    g_nsmp        =   50 ;number of samples for significance test

    g_year_leap   =   0
    g_run_period  =   "0250-0299"
        
    g_font = 0.025
    g_var         = "TS"

    g_fig_name    =   "../fig/diff_SST_HEAT_MAM-CON_ann"
    g_fig_title   =   "HEAT_MAM-CON"


;*************************For B_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path+g_ctrl_case+"."+g_var+".mon."+g_run_period+".nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	
	ctrl_var3  = ctrl_in1->TS(g_year_leap*12:,:,:)			; p for unify the var name
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================


	ctrl_var3_season = month_to_annual (ctrl_var3, 1)

	ctrl_var3_season_clim = dim_avg_n_Wrap(ctrl_var3_season,0)

	ctrl_var3_var = dim_variance_n(ctrl_var3_season,0)



	do i = 0,dimsizes(g_sen_cases)-1
;*************************For F_Compset Heat***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	exp_file1   = g_data_path+g_sen_cases(i)+"."+g_var+".mon."+g_run_period+".nc"
	exp_in1     = addfile (exp_file1, "r")   ; note the "s" of addfile
	
	exp_var3  = exp_in1->TS(g_year_leap*12:,:,:)			; p for unify the var name
    
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================

	exp_var3_season = month_to_annual (exp_var3, 1)

	exp_var3_season_clim = dim_avg_n_Wrap(exp_var3_season,0)

	exp_var3_var = dim_variance_n(exp_var3_season,0)

	diff_var3 = exp_var3_season_clim	

	diff_var3 = (exp_var3_season_clim-ctrl_var3_season_clim)		
	diff_var3_sig = diff_var3

		;============================================================
		;Sig test
		;============================================================

		sigr = 0.05                        ; critical sig lvl for r

		iflag= False                        ; population variance similar
		prob3 = ttest(ctrl_var3_season_clim,ctrl_var3_var,g_nsmp, exp_var3_season_clim,exp_var3_var,g_nsmp, iflag, False)
		
		diff_var3_sig=mask(diff_var3, prob3 .lt. sigr, True)
	end do
;-----------------------------------------------------------------------------
  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/2/),graphic)
  plot_tp = new((/2/),graphic)
  plot_sh = new((/2/),graphic)
  plot_V = new((/2/),graphic)

  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks1,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



  i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
  j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 ;res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 ;res@cnMinLevelValF        = -3.0          ; set min contour level
 ;res@cnMaxLevelValF        =  3.0          ; set max contour level
 ;res@cnLevelSpacingF       =  0.5          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
  ;res@gsnSpreadColorStart  = 2                ; start at color 17
  ;res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnLeftString = "(c)"
  res@gsnCenterString = "Upper-level temperature"
  res@gsnRightString = ""
  res@gsnStringFontHeightF = g_font

  res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1

  res@mpFillOn   = True;False     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  res@mpFillDrawOrder="PostDraw"
   res@mpCenterLonF = 180.
  res@mpMaxLatF  = latN
  res@mpMinLatF  = latS
  res@mpMaxLonF  = lonE
  res@mpMinLonF  = lonW

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
  res@tmXBTickSpacingF = 60
  res@tmYLTickSpacingF = 20
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
     


 res@gsnLeftString = "(a)"
 res@gsnCenterString = " HEAT - CON (CAM4)"

 plot(0) = gsn_csm_contour_map_ce(wks,diff_var3,res) ; create a default plot
 
; res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
; res@cnMinLevelValF        = -3.          ; set min contour level
; res@cnMaxLevelValF        =  3.          ; set max contour level
; res@cnLevelSpacingF       =  0.5          ; set contour interval
 

 res@gsnLeftString = "(a)"
 res@gsnCenterString = " CON_CP - CON (CAM4)"
; plot(1) = gsn_csm_contour_map_ce(wks,cp_diff_var3,res) ; create a default plot



;-------------------------------------------------------------------
  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  res3@cnLineLabelsOn   = False      ; turn off contour line labels
  res3@cnLineThicknessF = 2
  res3@cnLineColor      = "black"
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/3000,1000/)
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "


  ;plot_tp = gsn_csm_contour(wks,phis,res3)

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
  res4@cnFillPattern = 17
  res4@cnMonoFillScale = True
  res4@cnFillScaleF = 1.
  res4@cnMonoFillColor = True
  res4@cnFillColor  =  "red"
  res4@cnFillDotSizeF = 0.003
 
  res4@lbLabelBarOn = False;True   ; turn off the label bar
 
;  res4@cnLevelSelectionMode="ExplicitLevels"
;  res4@cnLevels = (/3000,1000/)
  res4@gsnLeftString      = " "
  res4@gsnRightString      = " "
;-----------------------------------------------------------------------------
          
  vcres = True
  vcres@gsnDraw          = False           ; don't draw
  vcres@gsnFrame         = False           ; don't advance frame
  vcres@gsnRightString   = " "             ; turn off right string
  vcres@gsnLeftString    = " "             ; turn off left string
  vcres@gsnCenterString    = " "
 
  vcres@vcRefAnnoOn      = True
  vcres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
  vcres@vcRefMagnitudeF         = 5.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.017
  vcres@vcRefAnnoString1  = "5 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.01
 
  vcres@vcLineArrowThicknessF     = 1.5    ;thickness of vector
;  vcres@vcLineArrowHeadMinSizeF   = 0.010
;  vcres@vcLineArrowHeadMaxSizeF   = 0.130
;--------------------------------------

  ;plot_V(0) = gsn_csm_vector(wks,diff_var1,diff_var2,vcres)

  ;plot_V(1) = gsn_csm_vector(wks,cp_diff_var1,cp_diff_var2,vcres)

  plot_sh(0) = gsn_csm_contour(wks,diff_var3_sig,res4)

 ; plot_sh(1) = gsn_csm_contour(wks,cp_diff_var3_sig,res4)

  ;overlay(plot(0),plot_sh(0))
  ;overlay(plot(1),plot_sh(1))

  ;overlay(plot(0),plot_V(0))
  ;overlay(plot(1),plot_V(1))

 
  gsn_panel(wks,plot(0),(/1,1/),False)

  draw(plot)
  frame(wks)
end 
