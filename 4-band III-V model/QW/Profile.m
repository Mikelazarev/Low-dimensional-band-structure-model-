%PAl = Profile(z, P0, P1, P2, P3, P4, d1, d2, d3, d4)

function PAl = Profile(z, P0, P1, P2, P3, Ps, d1, d2, d3, ds, s1,s2,ss)

PAL=P0*ones(size(z));
PAl(find(-(0.5*d2+s1+d1)<z<-(0.5*d2+s1))) = P1; 
Al(find(-0.5*d2<z<0.5*d2)) = P2;
Al(find((0.5*d2+s2)<z<(0.5*d2+s2+d3))) = P3;
Al(find((ss)<z<(ds+ss))) = Ps;