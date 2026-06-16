del all.ind
del all.glo
del all.toc
del *.aux
set TEX=latex
mp majority.mp
copy majority.1 majority-1.mps
pdflatex --tcx=koi2t2 all
pdflatex --tcx=koi2t2 all
pdflatex --tcx=koi2t2 all
rmakeindex -koi -s ..\macros\all.ist all.idx
rmakeindex -koi -s ..\macros\allglo.ist -o all.gls all.glo
pdflatex --tcx=koi2t2 all
pdflatex --tcx=koi2t2 all
pdflatex --tcx=koi2t2 all