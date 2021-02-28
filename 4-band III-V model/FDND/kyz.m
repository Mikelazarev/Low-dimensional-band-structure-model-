function M = kyz(F, X, Y, Z)
    [Sy, Sx, Sz] = size(X);
    Stot = Sx*Sy*Sz;
    F = spdiags(reshape(F, Stot, 1), 0, Stot, Stot);
    M = (Dyapprx(X, Y, Z)*F*Dzapprx(X, Y, Z) + Dzapprx(X, Y, Z)*F*Dyapprx(X, Y, Z))/2;
    M = (-1i)^2*M;