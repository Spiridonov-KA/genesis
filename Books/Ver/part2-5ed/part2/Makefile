mps: ;                                          \
       mpost majority.mp;                       \
       mv majority.1 majority-1.mps;            \
       rm *.log;                               \


booklet: dvi;                                           \
      dvips -t a4 -o all1200.ps -D 1200 all;               \
      psbook -s32 < all1200.ps | pstops -pa4 '2:0L@1(217mm,5.5mm)+1L@1(217mm,14.85cm)' > booklet.ps; \

include ../macros/Makefile
