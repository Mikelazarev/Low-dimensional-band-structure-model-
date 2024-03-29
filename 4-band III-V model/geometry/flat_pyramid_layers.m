
%[C, z] = flat_pyramid_layers(x, y, conc, r, w)
%conc = [bulk VQW VQWR]

function [C, z] = flat_pyramid_layers(x, y, conc, r, w)

if nargin<5         %number of function arguments
    w = 2*r/(1.2);  %width of the VQW
end

N = max([size(conc, 1) size(w, 1) size(r, 1) ]);  %Number of different layers

if length(r)==1
    r = kron(ones(N, 1), r);
end

if length(w)==1
    w = kron(ones(N, 1), w);
end

if size(conc, 1)==1
    conc = kron(ones(N, 1), conc);
end


if size(conc, 2)>3
    dZ = conc(:,4);             %Thickness of each layer
else
    dZ = ones(size(conc, 1), 1);
end

Ztot = sum(dZ);                 %Total thickness
C = zeros(length(y), length(x), Ztot);

%build layer by layer

indx = 1;
for i=1:length(dZ)%layer
    for j=1:dZ(i)%thickness of the ith layer
        C(:,:,indx) = flat_pyramid_layer(x, y, conc(i, 1:3), w(i), r(i)); 
        indx = indx+1;
    end
end

z = 1:Ztot; z = z - mean(z);

function [C, x, y] = flat_pyramid_layer(x, y, conc, w, r)
sy = length(y);
sx = length(x);
if isnan(w)     %there are array elements that are NaN
    C_QWs = zeros(sy, sx);
else
    C_QWs = buildVQW(x, y, 0, w, 0, 0);
end

if isnan(r)
    C_QWR = zeros(sy, sx);
else
    C_QWR = buildVQWR(x, y, r, 0, 0);
end



C = conc(1)*ones(sy, sx);
C(find(C_QWs==1)) = conc(2);
C(find(C_QWR==1)) = conc(3);


function C = buildVQWR(x, y, r, y0, x0);
[X, Y] = meshgrid(x-x0, y-y0);
R = sqrt(X.^2 + Y.^2);
C = zeros(size(X));
C(find(R<r)) = 1;



