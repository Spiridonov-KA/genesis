dvi: mps;                                                \
      latex --translate-file=../macros/koi2t2 all;            \
      latex --translate-file=../macros/koi2t2 all;            \
      latex --translate-file=../macros/koi2t2 all;            \
      rmakeindex -koi -s ../macros/all.ist -o all.ind all;         \
      rmakeindex -koi -s ../macros/allglo.ist -o all.gls all.glo;  \
      latex --translate-file=../macros/koi2t2 all;            \
      latex --translate-file=../macros/koi2t2 all;            \
      latex --translate-file=../macros/koi2t2 all;            \
      rm all.glo all.gls *.aux all.idx;                  \
      rm all.ilg all.ind all.log all.toc;                \

ps: dvi;                                         \
      dvips -t a4 -o all1200.ps -D 1200 all;               \
      dvips -t a4 -o all600.ps -D 600 all;                 \
      psselect "-p_,1-" all600.ps tmp.ps;               \
      pstops -pa4 "2:0L@1(217mm,5.5mm)+1L@1(217mm,14.85cm)" < tmp.ps > all.2.ps; \
      rm tmp.ps;                                        \
      dvips -t a4 -D1200 -h mirr.hd -o all-m.ps all;    \
      psselect "-p_,1-" all-m.ps tmp.ps;               \
      pstops -pa4 "2:1L@1(217mm,0.65cm)+0L@1(217mm,15cm)" < tmp.ps > all.m2.ps; \
      rm tmp.ps all-m.ps;                               \

publisher: ps;                                          \
      zip publisher.zip all.m2.ps all.2.ps;            \

pdf: mps;                                                  \
      pdflatex --translate-file=../macros/koi2t2 all;            \
      pdflatex --translate-file=../macros/koi2t2 all;            \
      pdflatex --translate-file=../macros/koi2t2 all;            \
      rmakeindex -koi -s ../macros/all.ist -o all.ind all;           \
      rmakeindex -koi -s ../macros/allglo.ist -o all.gls all.glo;    \
      pdflatex --translate-file=../macros/koi2t2 all;            \
      pdflatex --translate-file=../macros/koi2t2 all;            \
      pdflatex --translate-file=../macros/koi2t2 all;            \

clean: ;                                                 \
      rm all.glo all.gls all.aux all.idx;                \
      rm all.ilg all.ind all.log all.toc;                \
      rm *.mpx *.mps *.log *.pdf *.aux red.tmp;          \
      rm *.dvi *.ps *.out;                               \
      rm *.synctex.gz;                                   \

printbooklet: booklet; \
      lpr -o raw ../macros/booklet.pjl; \
      lpr -o raw booklet.ps
