\beginfig(1);

numeric u;
u=3.5cm;

draw (0u,0u)--(0u,1u)--(1u,1u)--(1u,0u)--cycle;
draw (0u,0u)--(1u,1u) dashed evenly;

pickup pencircle scaled 1pt;

draw (0,0)
   for i=1 upto 20: ..(i/20, (i/20)*(i/20)*(3-2*(i/20)))*u endfor;

endfig;

bye
