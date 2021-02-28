%function ple2_plotExported()
%plot ple graphs from exported data from ple2()
%ple is a strusture (cut eng, integration range, x, y)
% x can be spectrum number, power, exc eng. ...

allPle = who('-regexp','ple');
N = size(allPle,1);


figure;
hold on;
for i=1:N
    p = eval(char(allPle(i)));
    if p.cut<1580
        plot(pow(p.x),p.y,'b-o','DisplayName', sprintf('%.2f',p.cut));
    else
        plot(pow(p.x),p.y,'r-o','DisplayName', sprintf('%.2f',p.cut));
    end
    
end


clear allPle;
clear i;