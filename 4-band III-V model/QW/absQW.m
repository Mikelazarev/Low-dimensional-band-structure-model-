%%plot absorption spectrum
figure;
x1=zeros(size(out.E.E));
x1=x1';
for i=1:size(out.E.E);
        x1(i)=1;
        Elh1(i) = 1.5192 + out.E.E(i) + out.LH.E(i);
        Ehh1(i) = 1.5192 + out.E.E(i) + out.HH.E(i);

        
end

for i=1:size(out.E.E);
        stem(Elh1, x1, 'bo');
        text(Elh1(i)-0.0005, x1(i)+0.1, ['\color{blue}' 'e',num2str(i),'lh',num2str(i)]);
        hold on;
        stem(Ehh1, x1, 'ro');
        text(Ehh1(i)-0.0005, x1(i)+0.05, ['\color{red}' 'e',num2str(i),'hh',num2str(i)]);
        
end
axis([1.5 1.68 0 1.2]); 

%%plot probability density functions

figure;
subplot(2, 1, 1);

%%electron wavefunctions
for i=1:size(out.E.E);    
    hold on;  
    h=area(out.cparam.z, 1.5192+ out.E.E(i)+ (out.E.WF(1:size(out.E.WF),i).^2).*0.5, 1.5192+ out.E.E(i)); 
    set(h,'FaceColor','g');
    hold on;
end

axis([-95 95 1.55 1.65]); 
plot(out.cparam.z, 1.5192 + (1.707*out.cparam.Al - 1.437*out.cparam.Al.^2 + 1.310*out.cparam.Al.^3).*0.62,'b');

subplot(2, 1, 2 );

%%hole wavefunctions
for i=1:size(out.E.E);   
    h=area(out.cparam.z, - out.LH.E(i) - (out.LH.WF(1:size(out.LH.WF),i).^2).*0.5, out.LH.E(i).*-1);  
    set(h,'FaceColor','b');
    hold on;
    h=area(out.cparam.z, - out.HH.E(i) - (out.HH.WF(1:size(out.HH.WF),i).^2).*0.5, out.HH.E(i).*-1);  
    set(h,'FaceColor','r');
end
axis([-95 95 -0.040 0]); 
plot(out.cparam.z,(1.707*out.cparam.Al - 1.437*out.cparam.Al.^2 + 1.310*out.cparam.Al.^3).*(-0.38));