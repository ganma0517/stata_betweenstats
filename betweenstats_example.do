*===============================================================*
* betweenstats — example / tutorial do-file
* Uses the bundled practice data (fictional; no real-world source):
* reaction time (ms) under three imaginary training programs.
*===============================================================*
clear all
set more off

* load practice data from the repo (no install needed)
use "https://raw.githubusercontent.com/ganma0517/stata_betweenstats/main/betweenstats_demo.dta", clear

* ============================================================
* STYLE 1 — box + Kruskal-Wallis / Dunn (nonparametric)
* ============================================================
betweenstats score, by(group) type(box) test(np)

* ============================================================
* STYLE 2 — violin + Welch / Games-Howell + means (parametric)
* (load the 4-group satisfaction demo for this one)
* ============================================================
use "https://raw.githubusercontent.com/ganma0517/stata_betweenstats/main/betweenstats_demo2.dta", clear
betweenstats sat, by(layout) type(violin) test(param) means

* reload the first demo for the remaining examples
use "https://raw.githubusercontent.com/ganma0517/stata_betweenstats/main/betweenstats_demo.dta", clear

* other combinations
betweenstats score, by(group) test(param)
betweenstats score, by(group) type(violin) test(param) means

* ============================================================
* STYLE 3 — faceted by a panel variable
* (one sub-plot per level of panel(); auto columns)
* ============================================================
use "https://raw.githubusercontent.com/ganma0517/stata_betweenstats/main/betweenstats_demo3.dta", clear
betweenstats score, by(method) panel(subject)

* shared y-axis across panels
betweenstats score, by(method) panel(subject) ycommon

* 4) Show all pairwise brackets (including non-significant)
betweenstats score, by(group) showns

* 5) Custom titles + export
betweenstats score, by(group) type(violin) test(param) means ///
    title("Reaction time by training program") ///
    ytitle("Reaction time (ms)") xtitle("Program") ///
    saving("betweenstats_demo.png")

display as result "betweenstats tutorial finished — see help betweenstats."
