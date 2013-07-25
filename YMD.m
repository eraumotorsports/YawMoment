%% Yaw Moment Calculator
%  ERAU Motorsports

%% Initialize constants and add-ins
clear all; clc;

%Parameters
R = 120; %radius inches
fcamber = 2.5; %front camber degrees (do not enter negative, already assumed to be negative)
rcamber = 1.0; %rear camber degrees (do not enter negative, already assumed to be negative)
beta = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]; %body slip angle
delta = [-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6]; %front wheels steered angle

%Initialize OptimumT Add-in
% Check if the Addin has been loaded and if it has not load the Addin
A = exist('h', 'var');

if A == 0
    h = actxserver('OptimumT.Calculations');
end

% Check License
h.GetLicenseStatus

% Model Coefficient String
coef='BAAAAAAAMHAAAAAAFBMJCMEEOBGBKGODFOANCDBEIIBIHMPDHPNGDAAEHEFCNBPLLPGECCBEPADOOEPLDMGDMOPLEBDOMJODFKLNKMODCOPEHDOLBDNHBKBECCBHCHPDJPNNMJBEACIJFCAEJICEBJAEEOEOHHAEMNLIGHPDNNDBDFLLJOJOPNKLPAOBOFNDIHILELNDOEJHLMPDLAGFMKPDEGJBGDPLEJLCDBAMBGLPKFPDCAGILKAMMMHAEMBMEMNFCPBMNNGAEPLDKBIGGBAEJEIOANDMALANFBAEGIFMONIDNJECFLKLDMLEHFNLNDPAEAOLNNGHKKEEICAAKJEECBNJIKBEMHDHGFPLGDFBPFNLBGJHKBNDNBPHGJMDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJBOJCILLPIPIGGMLMPOELMNLELAFAENDMKDAMBAEGDOFJPPLKLCFBFPLAAAAAAAAMGFHPJPLNDODEEAEMLDHJNBEKIBADEPLALIPEIAMMDCELIODAPHLFANLCMCOMAPLHJEOBCBMAAAAAAAAOLIFJGMLJIDGBGNDPNEHELPDMFJJCMODMFMCFDBEJELFFJBEAPNFFFAEJBJFGNPLNCDHDAAMCKKDLPMLGGLGBBAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANMMMMIPDAAAAAIPDAAAAAIPDAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPD';

%% Load car parameters from Excel sheet
filename = 'WT_YMD.xlsx';

cp = CarParameters;
cp = cp.LoadFromExcel(filename);

b_mm = (cp.MassDistribution / 100) * cp.WheelBase;
a_mm = cp.WheelBase - b_mm;
a = a_mm*.0393701;
b = b_mm*.0393701;

%% For each beta, do a delta sweep and plot on a graph
for m = 1:13
    %Set corner G's to 0 in WT spread sheet
    A_y = 0;

    %Get FL FR RL RR static load from excel sheet
    [ FL,FR,RL,RR ] = wt( A_y, cp );

    %Calculate front slip angles (no ackerman)
    SF = (beta(m) + (a/R) - delta)*-1;

    %Calculate rear slip angles (no ackerman)
    SR = (beta(m) - (b/R))*-1;

    %Calculate Fy from Pacejka Model
    [FyFL, FyFR, FyRL, FyRR] = CalculateFy(0, h, FL, SF, fcamber, rcamber, coef);

    %Calculate lateral acceleration
    for i = 1:13
        A_y(i) = (FyFL(i) + FyFR(i) + FyRL + FyRR) / cp.Weight;
    end

    [A_y, YM] = CalculateYM(0, h, A_y, cp, SF, SR, fcamber, rcamber, coef);

    plot(A_y,YM)
    title('Yaw Moment Diagram')
    xlabel('Lateral Acceleration (G)')
    ylabel('Yaw Moment (Nm)')
    hold on
end

%% For each beta, do a delta sweep and plot on a graph
for m = 1:13
    %Set corner G's to 0 in WT spread sheet
    A_y = 0;

    %Get FL FR RL RR static load from excel sheet
    [ FL,FR,RL,RR ] = wt( A_y, cp );

    %Calculate front slip angles (no ackerman)
    SF = (beta + (a/R) - delta(m))*-1;

    %Calculate rear slip angles (no ackerman)
    SR = (beta - (b/R))*-1;

    %Calculate Fy from Pacejka Model
    [FyFL, FyFR, FyRL, FyRR] = CalculateFy(1, h, FL, SF, fcamber, rcamber, coef);

    %Calculate lateral acceleration
    for i = 1:13
        A_y(i) = (FyFL(i) + FyFR(i) + FyRL(i) + FyRR(i)) / cp.Weight;
    end

    [A_y, YM] = CalculateYM(1, h, A_y, cp, SF, SR, fcamber, rcamber, coef);

    plot(A_y,YM)
    title('Yaw Moment Diagram')
    xlabel('Lateral Acceleration (G)')
    ylabel('Yaw Moment (Nm)')
    hold on
end
