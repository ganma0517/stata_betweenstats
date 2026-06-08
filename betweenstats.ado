*! betweenstats v1.2  8Jun2026
*! Between-groups comparison plot (ggstatsplot-style):
*! box or violin + jittered points, an overall test in the header, and
*! pairwise-comparison brackets (significant pairs) at the top.
*! Supports faceting by a panel variable, optionally on a shared y-axis.
*!
*! Syntax:
*!   betweenstats yvar [if] [in] , by(groupvar) [ options ]
*!
*! ---- required ----
*!   by(varname)        grouping variable
*!
*! ---- plot type & test ----
*!   type(string)       "box" (default) or "violin"
*!   test(string)       "np" (Kruskal-Wallis + Dunn, default) or
*!                      "param" (Welch ANOVA + Games-Howell)
*!   alpha(#)           significance level for showing brackets (default .05)
*!   showns             also draw brackets for non-significant pairs
*!
*! ---- points & means ----
*!   nopoints           do not draw the jittered points
*!   jitter(#)          half-width of point jitter (default .18)
*!   msize(string)      point size (default small)
*!   means              add a mean dot and mu = value label to each group
*!   meancolor(string)  mean-dot colour (default dark red)
*!
*! ---- colours ----
*!   palette(string)    space-separated R G B triples, one per group
*!   bycolors(string)   explicit colour per group, as value=colour pairs, e.g.
*!                      bycolors(North=navy South=forest_green West=gs7)
*!                      (colors() is kept as a backward-compatible alias)
*!
*! ---- faceting (small multiples) ----
*!   panel(varname)     draw one sub-plot per level and combine them
*!   cols(#)            number of columns when faceting (default: auto)
*!   ycommon            shared (common) y-axis across all panels
*!
*! ---- titles & output ----
*!   title(string)      graph title
*!   ytitle(string)     y title (default = yvar label)
*!   xtitle(string)     x title (default = groupvar label)
*!   saving(string)     export path
*!   name(string)       graph window name (default betweenstats)

program define betweenstats
    version 16.0
    syntax varname(numeric) [if] [in] , by(varname)                      ///
        [                                                                ///
          TYPE(string) TEST(string) Alpha(real 0.05) SHOWNS             /// type & test
          NOPoints JITTER(real 0.18) MSize(string)                      /// points
          MEANs MEANColor(string)                                       /// means
          PALette(string) BYColors(string asis) COLORS(string asis)     /// colours
          BOXFill                                                       ///
          PANel(varname) COLs(integer 0) YCOMMON                        /// faceting
          YForce(numlist min=2 max=2)                                   ///
          title(string asis) YTITle(string asis) XTITle(string asis)    /// titles
          saving(string) name(string) ]

    local y `varlist'
    local g `by'

    * bycolors() is the documented name; colors() kept as backward-compatible alias
    if `"`bycolors'"'=="" local bycolors `"`colors'"'
    local colors `"`bycolors'"'

    * =====================================================
    * PANEL MODE: draw one betweenstats per level of panel()
    * and combine them into a single faceted graph.
    * =====================================================
    if "`panel'" != "" {
        if "`name'"=="" local name "betweenstats"
        tempvar ptouse
        marksample ptouse, novarlist
        markout `ptouse' `y' `g' `panel'
        quietly levelsof `panel' if `ptouse', local(plevs)
        local np : word count `plevs'
        if `cols'==0 {
            if `np'<=2 local cols = `np'
            else if `np'<=4 local cols = 2
            else local cols = 3
        }
        * collect passthrough options
        local opts `"type(`type') test(`test') alpha(`alpha') `nopoints' jitter(`jitter') `means' `boxfill'"'
        if "`msize'"!=""     local opts `"`opts' msize(`msize')"'
        if "`palette'"!=""   local opts `"`opts' palette(`palette')"'
        if `"`colors'"'!=""  local opts `"`opts' colors(`colors')"'
        if "`meancolor'"!="" local opts `"`opts' meancolor(`meancolor')"'
        if "`showns'"!=""    local opts `"`opts' showns"'
        if `"`ytitle'"'!=""  local opts `"`opts' ytitle(`"`ytitle'"')"'
        if `"`xtitle'"'!=""  local opts `"`opts' xtitle(`"`xtitle'"')"'

        * ycommon: find the global y-range across all panels and force it on each
        if "`ycommon'"!="" {
            quietly summarize `y' if `ptouse', meanonly
            local gymin = r(min)
            local gymax = r(max)
            local opts `"`opts' yforce(`gymin' `gymax')"'
        }

        local subnames ""
        local j = 0
        foreach pl of local plevs {
            local ++j
            * panel value label for the subtitle
            local plab : label (`panel') `pl'
            if `"`plab'"'=="" local plab "`pl'"
            local sub`j' "_bs_panel`j'"
            betweenstats `y' if `panel'==`pl' & `ptouse', by(`g') `opts' ///
                title("`plab'") name(`sub`j'')
            local subnames `subnames' `sub`j''
        }
        graph combine `subnames', cols(`cols') ///
            `=cond("`ycommon'"=="","","ycommon")' ///
            `=cond(`"`title'"'=="","",`"title(`"`title'"')"')' ///
            graphregion(color(white)) name(`name', replace)
        if `"`saving'"' != "" {
            quietly graph export `"`saving'"', replace width(2600)
            di as result "saved: `saving'"
        }
        exit
    }

    marksample touse
    markout `touse' `by'

    if "`type'"=="" local type "box"
    if !inlist("`type'","box","violin") {
        di as error "type() must be box or violin"
        exit 198
    }
    if "`test'"=="" local test "np"
    if !inlist("`test'","np","param") {
        di as error "test() must be np or param"
        exit 198
    }
    if "`msize'"=="" local msize "small"
    if "`meancolor'"=="" local meancolor "150 20 20"
    if "`name'"=="" local name "betweenstats"
    if `"`ytitle'"'=="" {
        local ytl : variable label `y'
        if `"`ytl'"'=="" local ytl "`y'"
        local ytitle `"`ytl'"'
    }
    if `"`xtitle'"'=="" {
        local xtl : variable label `g'
        if `"`xtl'"'=="" local xtl "`g'"
        local xtitle `"`xtl'"'
    }
    foreach t in title ytitle xtitle {
        local tv `"``t''"'
        if substr(`"`tv'"',1,1)==`"""' & substr(`"`tv'"',-1,1)==`"""' {
            local `t' = substr(`"`tv'"',2,length(`"`tv'"')-2)
        }
    }

    * default palette (teal, orange, purple, pink, blue, ...)
    if "`palette'"=="" {
        local palette "37 165 137  230 126 60  106 90 205  219 88 144  70 90 200  200 160 40"
    }

    preserve
    quietly keep if `touse'
    quietly keep `y' `g'

    * ---- group levels, positions, value labels ----
    tempvar gid
    capture confirm numeric variable `g'
    if _rc quietly egen `gid' = group(`g')
    else   quietly gen double `gid' = `g'

    quietly levelsof `gid', local(glevs)
    local k : word count `glevs'
    if `k' < 2 {
        di as error "need at least 2 groups"
        exit 198
    }

    local i = 0
    foreach gl of local glevs {
        local ++i
        local pos`gl' = `i'
        * x-axis label: prefer the value label of the original group variable
        quietly levelsof `g' if `gid'==`gl', local(gval) clean
        local lb : label (`g') `gval'
        if `"`lb'"'=="" | "`lb'"=="`gval'" {
            * string grouping var, or no value label -> use the raw value
            capture confirm numeric variable `g'
            if _rc {
                quietly levelsof `g' if `gid'==`gl', local(lb) clean
            }
            else local lb "`gval'"
        }
        local lab`gl' `"`lb'"'
        local xlab `xlab' `i' `"`lb'"'
        * resolve this group's colour: default = palette RGB triple for this
        * position; an explicit colors("group=colour") mapping overrides it
        * (key may be the group's value label or its raw value).
        local r1 : word `=(`i'-1)*3+1' of `palette'
        local g1 : word `=(`i'-1)*3+2' of `palette'
        local b1 : word `=(`i'-1)*3+3' of `palette'
        local gcol`gl' "`r1' `g1' `b1'"
        if `"`colors'"'!="" {
            foreach kv of local colors {
                local eq = strpos(`"`kv'"',"=")
                if `eq' {
                    local kk = substr(`"`kv'"',1,`eq'-1)
                    local cc = substr(`"`kv'"',`eq'+1,.)
                    if `"`kk'"'==`"`lb'"' | `"`kk'"'=="`gval'" local gcol`gl' `"`cc'"'
                }
            }
        }
        * stats
        quietly summarize `y' if `gid'==`gl', detail
        local n`gl'  = r(N)
        local md`gl' = r(p50)
        local q1`gl' = r(p25)
        local q3`gl' = r(p75)
        local mean`gl' = r(mean)
        local sd`gl'   = r(sd)
        * whisker bounds (Tukey 1.5 IQR, clamped to data)
        local iqr = `q3`gl'' - `q1`gl''
        quietly summarize `y' if `gid'==`gl' & `y'>=`q1`gl''-1.5*`iqr', meanonly
        local wlo`gl' = r(min)
        quietly summarize `y' if `gid'==`gl' & `y'<=`q3`gl''+1.5*`iqr', meanonly
        local whi`gl' = r(max)
    }

    quietly summarize `y', meanonly
    local ymin = r(min)
    local ymax = r(max)
    * common-scale override: use the global range for the axis floor/ceiling
    if "`yforce'"!="" {
        local gy1 : word 1 of `yforce'
        local gy2 : word 2 of `yforce'
        local ymin = `gy1'
        local ymax = `gy2'
    }
    local yr = `ymax' - `ymin'

    * =====================================================
    * OVERALL TEST
    * =====================================================
    if "`test'"=="np" {
        * Kruskal-Wallis
        quietly kwallis `y', by(`gid')
        local chi2 = r(chi2_adj)
        if "`chi2'"=="" | `chi2'==. local chi2 = r(chi2)
        local df = `k'-1
        local pall = chi2tail(`df', `chi2')
        quietly count
        local Ntot = r(N)
        local c2s : display %6.2f `chi2'
        local ps  : display %8.2e `pall'
        local head "Kruskal-Wallis: chi2(`df') = `=trim("`c2s'")', p = `=trim("`ps'")', N = `Ntot'"
    }
    else {
        * Welch's ANOVA
        tempname num den gsum wsum
        local Wnum = 0
        local Wden = 0
        local sumw = 0
        local sumwx = 0
        foreach gl of local glevs {
            local w`gl' = `n`gl'' / (`sd`gl''^2)
            local sumw = `sumw' + `w`gl''
            local sumwx = `sumwx' + `w`gl''*`mean`gl''
        }
        local xbar = `sumwx'/`sumw'
        local A = 0
        local B = 0
        foreach gl of local glevs {
            local A = `A' + `w`gl''*(`mean`gl''-`xbar')^2
            local B = `B' + (1-`w`gl''/`sumw')^2/(`n`gl''-1)
        }
        local A = `A'/(`k'-1)
        local B = 2*(`k'-2)/(`k'^2-1)*`B'
        local F = `A'/(1+`B')
        local df1 = `k'-1
        local df2 = (`k'^2-1)/(3*( ///
            0)+0)   // placeholder, recompute below
        * df2 (Welch)
        local sden = 0
        foreach gl of local glevs {
            local sden = `sden' + (1-`w`gl''/`sumw')^2/(`n`gl''-1)
        }
        local df2 = (`k'^2-1)/(3*`sden')
        local pall = Ftail(`df1',`df2',`F')
        quietly count
        local Ntot = r(N)
        local df2s : display %5.1f `df2'
        local Fs   : display %6.2f `F'
        local ps   : display %8.2e `pall'
        local head "Welch F(`df1', `=trim("`df2s'")') = `=trim("`Fs'")', p = `=trim("`ps'")', N = `Ntot'"
    }

    * =====================================================
    * PAIRWISE TESTS  (build list of pairs + p, Holm-corrected)
    * =====================================================
    * rank once for Dunn
    if "`test'"=="np" {
        tempvar rnk
        quietly egen double `rnk' = rank(`y')
        quietly count
        local Nall = r(N)
        * tie correction
        tempvar tie
        quietly bysort `y': gen double `tie' = _N
        quietly gen double _tt = `tie'^3 - `tie'
        quietly summarize _tt, meanonly
        local Tsum = r(sum)/(_N)   // not used directly; recompute below
        * mean rank per group
        foreach gl of local glevs {
            quietly summarize `rnk' if `gid'==`gl', meanonly
            local R`gl' = r(mean)
        }
        * sum of (t^3-t) over tie groups
        tempvar tg
        quietly egen `tg' = tag(`y')
        quietly gen double _t3 = (`tie'^3 - `tie') if `tg'
        quietly summarize _t3, meanonly
        local Tcorr = r(sum)
    }

    local np = 0
    local idx = 0
    foreach a of local glevs {
        foreach b of local glevs {
            if `a' < `b' {
                local ++idx
                if "`test'"=="np" {
                    * Dunn z (use lower tail to avoid underflow at large z)
                    local sig = sqrt( (`Nall'*(`Nall'+1)/12 - `Tcorr'/(12*(`Nall'-1))) * (1/`n`a'' + 1/`n`b'') )
                    local z = abs(`R`a'' - `R`b'') / `sig'
                    local praw = 2*normal(-`z')
                    * keep log-p for very small values
                    local lp`idx' = ln(2) + lnnormal(-`z')
                }
                else {
                    * Games-Howell
                    local se = sqrt( (`sd`a''^2/`n`a'') + (`sd`b''^2/`n`b'') )
                    local t = abs(`mean`a'' - `mean`b'') / `se'
                    local dfn = ( (`sd`a''^2/`n`a'') + (`sd`b''^2/`n`b'') )^2
                    local dfd = (`sd`a''^2/`n`a'')^2/(`n`a''-1) + (`sd`b''^2/`n`b'')^2/(`n`b''-1)
                    local dfgh = `dfn'/`dfd'
                    * studentized range -> use t approx: q = t*sqrt(2); p from tukeyprob unavailable,
                    * approximate with 2-sided t (conservative-ish)
                    local praw = 2*ttail(`dfgh', `t')
                    * log-p via normal approx for tiny values
                    local lp`idx' = ln(2) + lnnormal(-`t')
                }
                local pr`idx' = `praw'
                local pa`idx' = `a'
                local pb`idx' = `b'
            }
        }
    }
    local npairs = `idx'

    * ---- Holm correction ----
    * order p ascending, apply (m - rank +1) factor, enforce monotonicity
    local m = `npairs'
    * simple bubble sort of indices by praw
    forvalues r = 1/`m' {
        local ord`r' = `r'
    }
    forvalues i2 = 1/`m' {
        forvalues j2 = 1/`=`m'-1' {
            local jj = `ord`j2''
            local kk = `ord`=`j2'+1''
            if `pr`jj'' > `pr`kk'' {
                local ord`j2' = `kk'
                local ord`=`j2'+1' = `jj'
            }
        }
    }
    local prev = 0
    forvalues r = 1/`m' {
        local id = `ord`r''
        local factor = `m' - `r' + 1
        local padj = `factor'*`pr`id''
        if `padj' > 1 local padj = 1
        if `padj' < `prev' local padj = `prev'
        local prev = `padj'
        local phadj`id' = `padj'
        * Holm-adjusted log-p (for tiny values that underflow to 0)
        local lphadj`id' = ln(`factor') + `lp`id''
    }

    * =====================================================
    * BUILD PLOT LAYERS
    * =====================================================
    * jittered points
    tempvar xj
    quietly gen double `xj' = .
    foreach gl of local glevs {
        quietly replace `xj' = `pos`gl'' + runiform(-`jitter',`jitter') if `gid'==`gl'
    }

    local plot ""
    local ci = 0
    if "`nopoints'"=="" {
        foreach gl of local glevs {
            local ++ci
            local col "`gcol`gl''"
            local plot `"`plot' (scatter `y' `xj' if `gid'==`gl', mcolor("`col'%55") msize(`msize') msymbol(O)) "'
        }
    }

    * box or violin per group
    local bw = 0.20
    local ci2 = 0
    foreach gl of local glevs {
        local ++ci2
        local xc = `pos`gl''
        local xl = `xc' - `bw'
        local xr = `xc' + `bw'

        if "`type'"=="violin" {
            * group color
            local vcol "`gcol`gl''"
            * kernel density at 48 evaluation points
            tempvar kx kd
            quietly kdensity `y' if `gid'==`gl', nograph generate(`kx' `kd') n(48)
            quietly summarize `kd', meanonly
            local kmax = r(max)
            local vw = 0.42   // max half-width of violin
            * filled look: stacked thin horizontal strips
            forvalues j = 1/48 {
                local yj  = `kx'[`j']
                local dj  = `kd'[`j']
                if `yj'<. & `dj'<. {
                    local hw = `vw'*`dj'/`kmax'
                    local plot `"`plot' (pci `yj' `=`xc'-`hw'' `yj' `=`xc'+`hw'', lcolor("`vcol'%18") lwidth(vthin)) "'
                }
            }
            * outline (connect consecutive points on each side)
            forvalues j = 1/47 {
                local y1 = `kx'[`j']
                local d1 = `kd'[`j']
                local y2 = `kx'[`=`j'+1']
                local d2 = `kd'[`=`j'+1']
                if `y1'<. & `y2'<. & `d1'<. & `d2'<. {
                    local h1 = `vw'*`d1'/`kmax'
                    local h2 = `vw'*`d2'/`kmax'
                    local plot `"`plot' (pci `y1' `=`xc'-`h1'' `y2' `=`xc'-`h2'', lcolor("`vcol'") lwidth(vthin)) "'
                    local plot `"`plot' (pci `y1' `=`xc'+`h1'' `y2' `=`xc'+`h2'', lcolor("`vcol'") lwidth(vthin)) "'
                }
            }
        }

        * inner box (always drawn; slimmer when inside a violin)
        if "`type'"=="box" local bxw = `bw'
        else                local bxw = 0.085
        local bxl = `xc' - `bxw'
        local bxr = `xc' + `bxw'
        if "`type'"=="box" {
            local plot `"`plot' (pci `wlo`gl'' `xc' `q1`gl'' `xc', lcolor(black) lwidth(thin)) "'
            local plot `"`plot' (pci `q3`gl'' `xc' `whi`gl'' `xc', lcolor(black) lwidth(thin)) "'
        }
        * optional: fill the box with the group colour (stacked strips)
        if "`boxfill'"!="" & "`type'"=="box" {
            local fcol "`gcol`gl''"
            local nstrip = 40
            local hgt = `q3`gl'' - `q1`gl''
            forvalues s = 0/`nstrip' {
                local yy = `q1`gl'' + `hgt'*`s'/`nstrip'
                local plot `"`plot' (pci `yy' `bxl' `yy' `bxr', lcolor("`fcol'%70") lwidth(vthin)) "'
            }
        }
        local plot `"`plot' (pci `q1`gl'' `bxl' `q3`gl'' `bxl', lcolor(black) lwidth(medthin)) "'
        local plot `"`plot' (pci `q1`gl'' `bxr' `q3`gl'' `bxr', lcolor(black) lwidth(medthin)) "'
        local plot `"`plot' (pci `q1`gl'' `bxl' `q1`gl'' `bxr', lcolor(black) lwidth(medthin)) "'
        local plot `"`plot' (pci `q3`gl'' `bxl' `q3`gl'' `bxr', lcolor(black) lwidth(medthin)) "'
        local plot `"`plot' (pci `md`gl'' `bxl' `md`gl'' `bxr', lcolor(black) lwidth(medthick)) "'
    }

    * ---- mean dots + labels (optional) ----
    if "`means'"!="" {
        foreach gl of local glevs {
            local xc = `pos`gl''
            local plot `"`plot' (scatteri `mean`gl'' `xc', mcolor("`meancolor'") msize(medium) msymbol(O)) "'
            local ms : display %4.1f `mean`gl''
            local ms = trim("`ms'")
            local txt `txt' text(`mean`gl'' `=`xc'+0.16' "{&mu} = `ms'", size(vsmall) placement(e) color(black))
        }
    }

    * ---- significance brackets ----
    * start well above the data and use a generous gap between rows
    local top = `ymax' + 0.13*`yr'
    local step = 0.15*`yr'
    local tick = 0.022*`yr'
    local row = 0
    forvalues p = 1/`npairs' {
        local show = 0
        if `phadj`p'' < `alpha' local show = 1
        if "`showns'"!="" local show = 1
        if `show' {
            local ++row
            local a = `pa`p''
            local b = `pb`p''
            local xa = `pos`a''
            local xb = `pos`b''
            local H = `top' + (`row'-1)*`step'
            local Ht = `H' - `tick'
            local plot `"`plot' (pci `Ht' `xa' `H' `xa'  `H' `xa' `H' `xb'  `H' `xb' `Ht' `xb', lcolor(gs6) lwidth(thin)) "'
            * format p: use scientific notation for very small values.
            * when padj underflows to 0, rebuild from the log-p.
            if `phadj`p'' >= 0.001 {
                local pstr : display %6.3f `phadj`p''
                local pstr = trim("`pstr'")
            }
            else if `phadj`p'' > 0 {
                local pstr : display %8.1e `phadj`p''
                local pstr = trim("`pstr'")
            }
            else {
                * reconstruct a x 10^b from natural log
                local log10 = `lphadj`p''/ln(10)
                local expo = floor(`log10')
                local mant = 10^(`log10' - `expo')
                local ms : display %3.1f `mant'
                local pstr = trim("`ms'") + "e" + string(`expo')
            }
            local xm = (`xa'+`xb')/2
            local txt `txt' text(`=`H'+1.9*`tick'' `xm' "p = `pstr'", size(vsmall) placement(c) color(gs4))
        }
    }
    local ytop = `top' + (`row')*`step' + 0.08*`yr'

    quietly summarize `xj', meanonly
    local xmin = 0.5
    local xmax = `k' + 0.5

    twoway `plot' ///
        , legend(off) ///
          xlabel(`xlab', noticks) ///
          xscale(range(`xmin' `xmax')) ///
          xtitle(`"`xtitle'"') ///
          ytitle(`"`ytitle'"') ///
          yscale(range(`ymin' `ytop')) ///
          `=cond(`"`title'"'=="",`"title(`"`head'"', size(small))"',`"title(`"`title'"') subtitle(`"`head'"', size(small))"')' ///
          `txt' ///
          graphregion(color(white)) plotregion(margin(b=1)) ///
          name(`name', replace)

    if `"`saving'"' != "" {
        quietly graph export `"`saving'"', replace width(2200)
        di as result "saved: `saving'"
    }

    di as txt _n "Overall test: " as result "`head'"
    restore
end
