%ALL RESULTS APPEAR IN THE STRUCTURE Q
tic
YES = 1; NO = 0;
CB = YES;    CB_LEVELS = 10;

VB = YES;   VB_LEVELS = 20;

SPHERICAL_BANDS = NO;
COUPLING_OFF = NO;
STRAIN = NO;
PIEZO = NO;

HKL = '111';
kz = 0;

%%%DEFINE HIGH RESOLUTION COORDINATE SYSTEM ------------------------------
dx0 = 0.5; dy0 = 0.5;
x0 = -41:dx0:41;
y0 = -41:dy0:41;
z0 = 0;

%%%DEFINE POTENTIAL
C = buildVQW(x0, y0, z0, 15, -1, 0);
%Ct = buildTriangle(x0, y0, z0, 42, 0, 0);
[X, Y] = meshgrid(x0, y0); R = sqrt(X.^2+Y.^2); Ct = 0*R; Ct(find(R<DD/2)) = 1; %cylindrical crosssection
Ct = circshift(Ct, [0, -3]);
C(find(C==0))  = 0.30;
C(find(C==1))  = 0.13;
C(find(Ct==1)) = alvqwr;

mpfname = 'InAlGaAs_mparam_JAP89';

%%%DEFINE & LOAD MATERIAL PARAMETERS
if strcmp(mpfname, 'basic')
    disp('BASIC material parameters');
    mparam = generate_basic_mparam(0.065);
else
    mpfname = 'InAlGaAs_mparam_JAP89';
    disp(['Load material parameters: ' mpfname]);
    load(mpfname);
end

Q.mparam = mparam;
Q.mparam.file = mpfname; 
clear mpfname mparam;

dx = 1;
dy = 1;
x = -40:dx:40;
y = -40:dy:40;


%Resample the potential on the new low-res grid
Q.lrpot.C = single(resampleND(x0, y0, 0, C, x, y, 0));
Q.lrpot.x = x;
Q.lrpot.y = y;
Q.lrpot.z = 0;


if CB
    Q.CB.levels = CB_LEVELS;
    Q.CB.hamiltonian = 'Hc'
    [Q.CB.E, Q.CB.WF] = schrodND(Q, Q.CB.hamiltonian);
end




if VB
    Q.VB.kz = kz;
    Q.VB.levels = VB_LEVELS;
    Q.VB.spherical_approx = SPHERICAL_BANDS;
    Q.VB.coupling_off = COUPLING_OFF;
    Q.VB.hamiltonian = ['lutt2Dkz_' HKL];
    [Q.VB.E, Q.VB.WF] = schrodND(Q, Q.VB.hamiltonian);
end
toc

alal = 100*alvqwr;

save(['InfinitelongVQWR_' num2str(DD) 'VQWR' num2str(alal) 'per_v21'], 'Q')