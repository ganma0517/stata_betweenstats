{smcl}
{* *! version 1.0  1jun2026}{...}
{vieweralsosee "kwallis" "help kwallis"}{...}
{vieweralsosee "oneway" "help oneway"}{...}
{vieweralsosee "kdensity" "help kdensity"}{...}
{viewerjumpto "Syntax" "betweenstats##syntax"}{...}
{viewerjumpto "Description" "betweenstats##description"}{...}
{viewerjumpto "Options" "betweenstats##options"}{...}
{viewerjumpto "Examples" "betweenstats##examples"}{...}
{viewerjumpto "Author" "betweenstats##author"}{...}
{title:Title}

{phang}
{bf:betweenstats} {hline 2} Between-groups comparison plot with an overall test and pairwise brackets (ggstatsplot-style)


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:betweenstats}
{it:yvar}
{ifin}
{cmd:,}
{opth by(varname)}
[{it:options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent:* {opth by(varname)}}grouping variable (required){p_end}
{synopt:{opt type(string)}}{cmd:box} (default) or {cmd:violin}{p_end}
{synopt:{opt test(string)}}{cmd:np} = Kruskal-Wallis + Dunn (default), or {cmd:param} = Welch ANOVA + Games-Howell{p_end}
{synopt:{opt alpha(#)}}significance level for showing brackets; default {cmd:.05}{p_end}
{synopt:{opt showns}}also draw brackets for non-significant pairs{p_end}

{syntab:Points and means}
{synopt:{opt nopoints}}do not draw the jittered points{p_end}
{synopt:{opt jitter(#)}}half-width of point jitter; default {cmd:.18}{p_end}
{synopt:{opt msize(string)}}point marker size; default {cmd:small}{p_end}
{synopt:{opt means}}add a mean dot and {&mu} label to each group{p_end}
{synopt:{opt meancolor(string)}}mean-dot color; default dark red{p_end}
{synopt:{opt boxfill}}fill each box with its group colour (box type){p_end}

{syntab:Faceting}
{synopt:{opt panel(varname)}}draw one sub-plot per level of this variable and combine them{p_end}
{synopt:{opt cols(#)}}number of columns when faceting (default: auto){p_end}
{synopt:{opt ycommon}}use a shared (common) y-axis across all panels{p_end}

{syntab:Appearance}
{synopt:{opt palette(string)}}space-separated R G B triples, one color per group{p_end}
{synopt:{opt colors(string)}}explicit colour per group as {it:value=colour} pairs, e.g. {cmd:colors(KMT=blue DPP=green TPP=gs8)}{p_end}
{synopt:{opt title(string)}}graph title{p_end}
{synopt:{opt ytitle(string)}}y-axis title; default = {it:yvar} label{p_end}
{synopt:{opt xtitle(string)}}x-axis title; default = {it:groupvar} label{p_end}

{syntab:Saving}
{synopt:{opt saving(string)}}export the graph to this path{p_end}
{synopt:{opt name(string)}}graph window name; default {cmd:betweenstats}{p_end}
{synoptline}
{p 4 6 2}* {opt by()} is required.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:betweenstats} draws a between-groups comparison plot in the style of R's
{bf:ggstatsplot::ggbetweenstats}: a {bf:box} or {bf:violin} for each group with
jittered raw data points, the result of an {bf:overall test} in the header, and
{bf:pairwise-comparison brackets} (significant pairs by default) at the top with
Holm-adjusted p-values.

{pstd}
Two test families are built in (no external packages required):

{p 8 12 2}{bf:np} {hline 1} Kruskal-Wallis omnibus test with Dunn pairwise
comparisons (rank-based; matches the default ggbetweenstats nonparametric path).{p_end}
{p 8 12 2}{bf:param} {hline 1} Welch's ANOVA omnibus test with Games-Howell
pairwise comparisons (does not assume equal variances).{p_end}

{pstd}
All p-values use Holm correction. Pairwise p-values for very small values are
reported in scientific notation, reconstructed from the log scale to avoid
numeric underflow.


{marker options}{...}
{title:Options}

{phang}{opth by(varname)} is the grouping variable (string or numeric). Required.

{phang}{opt type(string)} selects {cmd:box} (default) or {cmd:violin}. The violin
is a kernel-density outline with a slim inner box.

{phang}{opt test(string)} selects {cmd:np} (Kruskal-Wallis + Dunn, default) or
{cmd:param} (Welch ANOVA + Games-Howell).

{phang}{opt alpha(#)} is the threshold for displaying a bracket (default .05).
With {opt showns}, all pairwise brackets are shown.

{phang}{opt nopoints}, {opt jitter(#)}, {opt msize(string)} control the raw-data
points.

{phang}{opt means} adds a colored mean dot and a {&mu} = value label to each
group; {opt meancolor(string)} sets its color.

{phang}{opt palette(string)} is a list of R G B triples (one per group), e.g.
{cmd:palette("37 165 137  230 126 60  106 90 205")}.

{phang}{opt colors(string)} assigns an explicit colour to specific groups as
{it:value=colour} pairs, e.g.
{cmd:colors(KMT=blue DPP=green TPP=gs8 中立無反應=black)}. The key may be the
group's value label or its raw value (use the raw value when the label contains
spaces); groups not listed keep their {opt palette()} colour. Use named colours
(e.g. {cmd:blue}, {cmd:gs8}).

{phang}{opt title()}, {opt ytitle()}, {opt xtitle()} set titles; {opt saving()}
exports the graph and {opt name()} names the graph window.


{marker examples}{...}
{title:Examples}

{pstd}Load the bundled practice data (fictional; no real source){p_end}
{phang2}{cmd:. use "https://raw.githubusercontent.com/ganma0517/stata_betweenstats/main/betweenstats_demo.dta", clear}{p_end}

{pstd}Box plot, Kruskal-Wallis + Dunn (default){p_end}
{phang2}{cmd:. betweenstats score, by(group)}{p_end}

{pstd}Box plot, Welch ANOVA + Games-Howell{p_end}
{phang2}{cmd:. betweenstats score, by(group) test(param)}{p_end}

{pstd}Violin plot with mean dots and {&mu} labels{p_end}
{phang2}{cmd:. betweenstats score, by(group) type(violin) test(param) means}{p_end}

{pstd}Show all pairwise brackets (including non-significant){p_end}
{phang2}{cmd:. betweenstats score, by(group) showns}{p_end}

{pstd}Faceted: one sub-plot per level of a panel variable{p_end}
{phang2}{cmd:. use "https://raw.githubusercontent.com/ganma0517/stata_betweenstats/main/betweenstats_demo3.dta", clear}{p_end}
{phang2}{cmd:. betweenstats score, by(method) panel(subject)}{p_end}


{marker author}{...}
{title:Author}

{pstd}{bf:Wen-Cheng Lin (林文正)}{break}
PhD student, Department of Political Science, National Chengchi University{break}
Postdoctoral research fellow, Institute of Sociology, Academia Sinica{break}
Email: beck740517@gmail.com{break}
{browse "https://github.com/ganma0517/stata_betweenstats":github.com/ganma0517/stata_betweenstats}{p_end}

{pstd}This package is a collaboration between the author and Claude. It is still
at an experimental stage and is intended mainly for presenting results from
survey-experiment and comparative designs. Questions and feedback are very welcome.{p_end}

{pstd}本套件是作者與 Claude 的協作成果，目前仍屬實驗性階段，主要用於調查實驗法與
比較研究的資訊呈現。若有任何問題，歡迎來信交流。{p_end}
