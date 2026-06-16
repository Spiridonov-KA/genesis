del all.ind
del all.glo
latex --tcx=koi2t2 all.tex
latex --tcx=koi2t2 all.tex
latex --tcx=koi2t2 all.tex
rmakeindex -koi -s ..\macros\all.ist -o all.ind all
rmakeindex -koi -s ..\macros\allglo.ist -o all.gls all.glo
latex --tcx=koi2t2 all.tex
latex --tcx=koi2t2 all.tex
latex --tcx=koi2t2 all.tex
dvips -o all.ps all
psselect -p_,1- all.ps tmp.ps
pstops 2:0L@1(297mm,0cm)+1L@1(297mm,14.85cm) < tmp.ps > all.2.ps
del tmp.ps
del all.ps