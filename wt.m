%function [ FL,FR,RL,RR ] = wt( A_y,fnsm,rnsm,mass,md,wb,tmcgh,fnsmcgh,rnsmcgh,fss,rss,fsmr,rsmr,frc,rrc,smri,ft,rt,farbs,farbmr,rarbs,rarbmr )
function [ FL,FR,RL,RR ] = wt( A_y, cp )
%WT Weight Transfer
%   Calculate dynamic wheel weights by using lateral acceleration

%Non suspended mass weight distribution
nsmd = cp.FrontNonSuspMass /(cp.RearNonSuspMass + cp.FrontNonSuspMass) * 100; % %Fr

%Suspended mass
sm = cp.Mass - 2 * cp.FrontNonSuspMass - 2 * cp.RearNonSuspMass; %kg

%Suspended mass weight distribution
smwd = (cp.Mass * cp.MassDistribution / 100 - cp.FrontNonSuspMass * 2) / sm * 100; % %Fr

%Suspended mass CG coordinates
smcgx = (100 - cp.MassDistribution) / 100 * cp.WheelBase; %mm
smcgy = 0; %mm
smcgz = (cp.Mass * cp.TotalMassCGHeight - (2 * cp.FrontNonSuspMass * cp.FrontNonSuspMassCGHeight + 2 * cp.RearNonSuspMass * cp.RearNonSuspMassCGHeight)) / sm; %mm

%Front wheel rate
fwr = cp.FrontSpringStiffness / cp.FrontSpringMotionRatio^2;

%Rear wheel rate
rwr = cp.RearSpringStiffness / cp.RearSpringMotionRatio^2;

%Z Distance from SM CG to front roll axis
zsmcgf = smcgz - cp.FrontRollCenter; %mm

%Z Distance from SM CG to rear roll axis
zsmcgr = smcgz - cp.RearRollCenter; %mm

%Z Distance from SM CG to roll axis @ SM CG
zsmcg = smcgz-(((cp.RearRollCenter - cp.FrontRollCenter) / cp.WheelBase * ((100 - smwd) / 100 * cp.WheelBase))+ cp.FrontRollCenter);

%Suspended mass inertia in roll
smi = cp.SuspMassRollInertia + sm * (zsmcg / 1000) ^ 2;

%A-R moment coming from
%front springs
armfs = ((cp.FrontTrack / 1000)^2 * tan(1 * (pi/180)) * (fwr * 1000))/2;
%rear springs
armrs = ((cp.RearTrack / 1000)^2 * tan(1 * (pi/180)) * (rwr * 1000))/2;
%total
arm_springs = armfs + armrs;

%A-R moment coming from
%front ARB
armfarb = cp.FrontARBStiffness / cp.FrontARBMotionRatio^2;
%rear ARB
armrarb = cp.RearTireStiffness / cp.RearARBMotionRatio^2;
%total
arm_arb = armfarb + armrarb;

%Anti-roll moment total
armt = arm_springs + arm_arb;

%Roll moment
rm = sm * 9.81 * A_y * zsmcg / 1000;

%Roll angle due to lat G
roll_angle = rm / armt;

%Front non suspended mass weight transfer
fnsmwt = cp.FrontNonSuspMass * 2 * A_y * cp.FrontNonSuspMassCGHeight / cp.FrontTrack;

%Rear non suspended mass weight transfer
rnsmwet = cp.RearNonSuspMass * 2 * A_y * cp.RearNonSuspMassCGHeight / cp.RearTrack;

%Front suspended elastic weight transfer
fsmelwt = (sm * A_y * zsmcg * (armfs + armfarb) / armt) / cp.FrontTrack;

%Rear suspended elastic weight transfer
rsmelwt = (sm * A_y * zsmcg * (armrs + armrarb) / armt) / cp.RearTrack;

%Front suspended geo weight transfer
fsmgwt = sm * (smwd / 100) * A_y * cp.FrontRollCenter / cp.FrontTrack;

%Rear suspended geo weight transfer
rsmgwt = sm * ((100 - smwd) / 100) * A_y * cp.RearRollCenter / cp.RearTrack;

%Front total weight transfer
ftwt = fnsmwt + fsmelwt + fsmgwt;

%Rear total weight transfer
rtwt = rnsmwet + rsmelwt + rsmgwt;

%Front left dynamic load
FL = (((cp.Mass * cp.MassDistribution / 100) / 2) - ftwt) * 9.81;

%Front right dynamic load
FR = (((cp.Mass * cp.MassDistribution / 100) / 2) + ftwt) * 9.81;

%Rear left dynamic load
RL = (((cp.Mass * (100- cp.MassDistribution ) / 100) / 2) - rtwt) * 9.81;

%Rear right dynamic load
RR = (((cp.Mass * (100- cp.MassDistribution ) / 100) / 2) + rtwt) * 9.81;

end

