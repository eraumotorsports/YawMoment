function [ FL,FR,RL,RR ] = wt( A_y,fnsm,rnsm,mass,md,wb,tmcgh,fnsmcgh,rnsmcgh,fss,rss,fsmr,rsmr,frc,rrc,smri,ft,rt,farbs,farbmr,rarbs,rarbmr )
%WT Weight Transfer
%   Calculate dynamic wheel weights by using lateral acceleration

%Non suspended mass weight distribution
nsmd = fnsm/(rnsm+fnsm)*100; % %Fr

%Suspended mass
sm = mass-2*fnsm-2*rnsm; %kg

%Suspended mass weight distribution
smwd = (mass*md/100-fnsm*2)/sm*100; % %Fr

%Suspended mass CG coordinates
smcgx = (100-md)/100*wb; %mm
smcgy = 0; %mm
smcgz = (mass*tmcgh-(2*fnsm*fnsmcgh+2*rnsm*rnsmcgh))/sm; %mm

%Front wheel rate
fwr = fss/fsmr^2;

%Rear wheel rate
rwr = rss/rsmr^2;

%Z Distance from SM CG to front roll axis
zsmcgf = smcgz-frc; %mm

%Z Distance from SM CG to rear roll axis
zsmcgr = smcgz-rrc; %mm

%Z Distance from SM CG to roll axis @ SM CG
zsmcg = smcgz-(((rrc-frc)/wb*((100-smwd)/100*wb))+frc);

%Suspended mass inertia in roll
smi = smri+sm*(zsmcg/1000)^2;

%A-R moment coming from
%front springs
armfs = ((ft/1000)^2 *tan(1*(pi/180))*(fwr*1000))/2;
%rear springs
armrs = ((rt/1000)^2 *tan(1*(pi/180))*(rwr*1000))/2;
%total
arm_springs = armfs+armrs;

%A-R moment coming from
%front ARB
armfarb = farbs/farbmr^2;
%rear ARB
armrarb = rarbs/rarbmr^2;
%total
arm_arb = armfarb+armrarb;

%Anti-roll moment total
armt = arm_springs+arm_arb;

%Roll moment
rm = sm*9.81*A_y*zsmcg/1000;

%Roll angle due to lat G
roll_angle = rm/armt;

%Front non suspended mass weight transfer
fnsmwt = fnsm*2*A_y*fnsmcgh/ft;

%Rear non suspended mass weight transfer
rnsmwet = rnsm*2*A_y*rnsmcgh/rt;

%Front suspended elastic weight transfer
fsmelwt = (sm*A_y*zsmcg*(armfs+armfarb)/armt)/ft;

%Rear suspended elastic weight transfer
rsmelwt = (sm*A_y*zsmcg*(armrs+armrarb)/armt)/rt;

%Front suspended geo weight transfer
fsmgwt = sm*(smwd/100)*A_y*frc/ft;

%Rear suspended geo weight transfer
rsmgwt = sm*((100-smwd)/100)*A_y*rrc/rt;

%Front total weight transfer
ftwt = fnsmwt+fsmelwt+fsmgwt;

%Rear total weight transfer
rtwt = rnsmwet+rsmelwt+rsmgwt;

%Front left dynamic load
FL = (((mass*md/100)/2)-ftwt)*9.81;

%Front right dynamic load
FR = (((mass*md/100)/2)+ftwt)*9.81;

%Rear left dynamic load
RL = (((mass*(100-md)/100)/2)-rtwt)*9.81;

%Rear right dynamic load
RR = (((mass*(100-md)/100)/2)+rtwt)*9.81;

end

