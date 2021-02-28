%ALL RESULTS APPEAR IN THE STRUCTURE Q
tic
YES = 1; NO = 0;
CB = YES;     CB_LEVELS = 3;
HH = NO;     HH_LEVELS = 2;
LH = NO;     LH_LEVELS = 2;

VB = YES;    VB_LEVELS = 6;

SPHERICAL_BANDS = NO;
COUPLING_OFF = NO;
STRAIN = NO;
PIEZO = NO;

HKL = [1 1 1];

%%%DEFINE HIGH RESOLUTION COORDINATE SYSTEM ------------------------------
dx0 = 0.25; dy0 = 0.25; dz0 = 0.1;
x0 = -25:dx0:25;
y0 = -25:dy0:25;

r =10;



    
 %5nm QD FLAT

conc = [
0.4	0.228571429	0.071942446	50/dz0;

0.1	0.5	0 6/dz0;

0.4	0.228571429	0.071942446	50/dz0;

]; %Cladding;


%{
INIT = 1;

RESAMPLE =1;

EFIELD = 0;

STRAIN = 1;

PIEZO = 1;

% Geometry, Parameters etc

 ASYM  = 1; %ASYM = 1 => Symmetric QD

 CURVE = 0.005; %CURVE = 0 => flat QD;

 cyl=0;

 




%%DEFINE COORDINATE SYSTEM ------------------------------

dx = 0.2; dy = dx; dz = dx;

 

x = -20:dx:20;

y = -20:dy:20;

z = -20:dz:20;

 

 

QD_t = 4;        %QD tickness [nm]

QD_r = 10;       %QD radius [nm]

gauss=0 %0.02;        %inhomogeneous indium concentration 0 is homogeneous

VQWR_l = 26;     %VQWR length [nm]

VQWR_r = 8;      %VQWR radius [nm)
Al_BULK=0.4;
 

Define geometrical structures and In/Al concentration distribution

Cylindrical QD with VQWR along the body diagonal [111] of the domain

 

c = Al_BULK*ones(length(y), length(x), length(z));

indx_VQWR = find(build_111_nearcyl_QD(x, y, z, 2*VQWR_r, VQWR_l, ASYM,gauss));

cIn = build_111_nearcyl_QD(x,y,z,2*QD_r, QD_t,  ASYM,gauss);

 

cIn = curve_111(cIn, CURVE);  %Add curvature to the QD  

indx_QD = find(cIn);

c(indx_VQWR)  = Al_VQWR;                  %Al concentration in VQWR

c(indx_QD)    = 1i*In_QD * cIn(indx_QD);  %In concentration in QD (In: imaginary Al: real)

%}

%[C_QD, z0] = flat_pyramid_layers(x0, y0, conc, r);
%z0 = z0*dz0;

%{

%Make tetraheder
TP =tetra_profile(x0, y0);
TP(find(TP<15)) = 15; TP = gaussBlur(TP, 5, 5, 5);
TP = TP - min(TP(:));

c0 = C_QD(:,:,size(C_QD,3));

TPV = zeros(size(C_QD));
for i=1:size(C_QD,3);
    TPV(:,:,i) = TP;
end
%}


%[X, Y, Z] = meshgrid(x0, y0, z0);
%C_QD = interp3(X, Y, Z, C_QD, X, Y, Z-TPV);

for i=1:size(C_QD,3);
    c_qd = C_QD(:,:,i);    c_qd(isnan(c_qd)) = c0(isnan(c_qd));    C_QD(:,:,i) = c_qd;
end

%C_QD = gaussBlur(C_QD, 2, 2, 2);
clear TP X Y Z TPV c0 c_qd;

%Diffusion model
%Ld = 4/dz0; %diffusion length
%C_QD = gaussBlur(C_QD, 0, 0, Ld);

C_VQWR = C_QD;
C_VQW = C_QD;
C = C_QD;
mpfname = 'InAlGaAs_mparam_JAP89';

Q.hrpot.C_QD = single(C_QD);
Q.hrpot.C_VQWR = single(C_VQWR);
Q.hrpot.C_VQW = single(C_VQW);
Q.hrpot.C = single(C);
Q.hrpot.x = x0;
Q.hrpot.y = y0;
Q.hrpot.z = z0;
clear C C_QD C_VQWR C_VQW

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

%%%DEFINE Z-DIRECTION OF CRYSTAL, Y direction is [-h k 0] and X follow
Q.hkl = HKL;   %Use NaN for principal axes

if STRAIN
%%%Simulate strain relaxation, result: strain fields
Q.strain = call_strainND(Q, 1);

%%%Extract coordinate system for used for strain simulation
xs = Q.strain.x;
ys = Q.strain.y;
zs = Q.strain.z;
end

if PIEZO
%%%Calculate the charge density
Q.piezo.rho = piezo_charge(Q.strain, Q.mparam, xs, ys, zs, Q.hkl, 'INV');

%%%Calculate the piezoelectric potential (felt by electrons)
[Q.piezo.V, Q.piezo.Vext] = call_poissonND(xs, ys, zs, Q.strain.c1 + (1i)*Q.strain.c2, Q.piezo.rho, 1);  %Result in eV
end


%%%DEFINE LOW RESOLUTION COORDINATE SYSTEM ------------------------------

%Hi Res
%dx = 0.9; dy = 0.9; dz = 0.5;
%x = -18:dx:18;
%y = -18:dy:18;
%z = -16:dz:16;*

dx = 2; dy = 2; dz = 5;
x = -25:dx:25;
y = -25:dy:25;
z = -30:dz:30;


%Resample the potential on the new low-res grid
Q.lrpot.C = single(resampleND(x0, y0, z0, Q.hrpot.C, x, y, z));
Q.lrpot.x = x;
Q.lrpot.y = y;
Q.lrpot.z = z;

if PIEZO
%Resample the piezo electric potential on the new low-res grid
Q.lrpiezo.V = resampleND(xs, ys, zs, Q.piezo.V, x, y, z);
end

if STRAIN
%Resample the strain on the new low-res grid
Q.lrstrain.c1 = real(Q.lrpot.C);
Q.lrstrain.c2 = imag(Q.lrpot.C);
Q.lrstrain.e_xx = resampleND(xs, ys, zs, Q.strain.e_xx, x, y, z);
Q.lrstrain.e_yy = resampleND(xs, ys, zs, Q.strain.e_yy, x, y, z);
Q.lrstrain.e_zz = resampleND(xs, ys, zs, Q.strain.e_zz, x, y, z);
Q.lrstrain.e_yz = resampleND(xs, ys, zs, Q.strain.e_yz, x, y, z);
Q.lrstrain.e_xz = resampleND(xs, ys, zs, Q.strain.e_xz, x, y, z);
Q.lrstrain.e_xy = resampleND(xs, ys, zs, Q.strain.e_xy, x, y, z);

Q.lrpot.HCfname = 'HCsparse';
Q.lrpot.BPfname = 'BPsparse';

if CB
%Extract strained CB Hamiltonian
Ham_HC_hkl(Q.lrstrain, Q.mparam, Q.lrpot.HCfname);
end

if VB
%Extract strained VB (BP) Hamiltonian
if (isnan(Q.hkl)|(Q.hkl == [0 0 1]))
    Ham_BP_001(Q.lrstrain, Q.mparam, Q.lrpot.BPfname);
elseif (Q.hkl == [1 1 1])
   Ham_BP_111(Q.lrstrain, Q.mparam, Q.lrpot.BPfname);
else
    disp('WARNING: No Bir-Pikus Hamiltonian defined for the choosen Z-axis!!');
end

end
end

if VB
Q.VB.levels = VB_LEVELS;
Q.VB.spherical_approx = SPHERICAL_BANDS;
Q.VB.coupling_off = COUPLING_OFF;


if (isnan(Q.hkl)|(Q.hkl == [0 0 1]))
    Q.VB.hamiltonian = 'lutt3D_001'
elseif (Q.hkl == [1 1 1])
    Q.VB.hamiltonian = 'lutt3D_111';
else
    disp('WARNING: No Luttinger Hamiltonian defined for the choosen Z-axis!!');
end
[Q.VB.E, Q.VB.WF] = schrodND(Q, Q.VB.hamiltonian);
end

if CB
    Q.CB.levels = CB_LEVELS;
    Q.CB.hamiltonian = 'Hc'
    [Q.CB.E, Q.CB.WF] = schrodND(Q, Q.CB.hamiltonian);
end

if HH
    Q.HH.levels = HH_LEVELS;
    Q.HH.hamiltonian = 'HH3D_111'
    [Q.HH.E, Q.HH.WF] = schrodND(Q, Q.HH.hamiltonian);
end

if LH
    Q.LH.levels = LH_LEVELS;
    Q.LH.hamiltonian = 'LH3D_111'
    [Q.LH.E, Q.LH.WF] = schrodND(Q, Q.LH.hamiltonian);
end



toc

%AAlba = Alba*100

%save(['Double_QD_2x9nm_barrier_6nm_' num2str(AAlba) '_Barrier'], 'Q')