*===============================================================*
* betweenstats — example / tutorial do-file
* Uses the bundled practice data (fictional; no real-world source):
* reaction time (ms) under three imaginary training programs.
*===============================================================*
clear all
set more off

* load practice data from the repo (no install needed)
use "https://raw.githubusercontent.com/ganma0517/stata_betweenstats/main/betweenstats_demo.dta", clear

* 1) Default: box + Kruskal-Wallis/Dunn
betweenstats score, by(group)

* 2) Box + Welch ANOVA/Games-Howell
betweenstats score, by(group) test(param)

* 3) Violin + means (mean dot + mu label)
betweenstats score, by(group) type(violin) test(param) means

* 4) Show all pairwise brackets (including non-significant)
betweenstats score, by(group) showns

* 5) Custom titles + export
betweenstats score, by(group) type(violin) test(param) means ///
    title("Reaction time by training program") ///
    ytitle("Reaction time (ms)") xtitle("Program") ///
    saving("betweenstats_demo.png")

display as result "betweenstats tutorial finished — see help betweenstats."
