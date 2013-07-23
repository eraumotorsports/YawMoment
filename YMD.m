clear
clc

%Parameters
R = 120; %radius inches
a = 32; %distance from CG to front axle
b = 32; %distance from CG to rear axle
beta = [-5 -4 -3 -2 -1 0 1 2 3 4 5]; %body slip angle
delta = [-5 -4 -3 -2 -1 0 1 2 3 4 5]; %front wheels steered angle

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

%Set excel file and sheet
filename = 'WT_YMD.xlsx';
sheet = 1;

%Set corner G's to 0 in WT spread sheet
A_y = 0;
xlRange = 'D35';
xlswrite(filename,A_y,sheet,xlRange);


%Get overall car mass from excel sheet
xlRange = 'D6';
mass = xlsread(filename,sheet,xlRange);
weight = mass *9.81;

%Get FL FR RL RR static load from excel sheet
%FL
xlRange = 'H23';
FL = xlsread(filename,sheet,xlRange)*9.81;

%FR
xlRange = 'I23';
FR = xlsread(filename,sheet,xlRange)*9.81;

%RL
xlRange = 'H24';
RL = xlsread(filename,sheet,xlRange)*9.81;

%RR
xlRange = 'I24';
RR = xlsread(filename,sheet,xlRange)*9.81;

%for each beta, do a delta sweep and plot on a graph

%Calculate front slip angles (no ackerman)
SF = (beta(1) + (a/R) - delta)*-1;

%Calculate rear slip angles (no ackerman)
SR = (beta(1) - (b/R))*-1;


%Loop
%Calculate Fy from Pacejka Model
for i = 1:11
    FyFL(i) = h.CalculateFy(FL,SF(i),0,0,11.176,2,coef);
    FyFR(i) = h.CalculateFy(FR,SF(i),0,0,11.176,2,coef);
end

FyRL = h.CalculateFy(RL,SR,0,0,11.176,2,coef);
FyRR = h.CalculateFy(RR,SR,0,0,11.176,2,coef);


%Calculate lateral acceleration
for i = 1:11
    A_y(i) = (FyFL(i) + FyFR(i) + FyRL + FyRR)/weight;
end


for i = 1:11

    converges = false;

    while converges == false

        %Calculate weight transfer
        %Set G's to "A-y" in WT spread sheet Get FL FR RL RR dynamic loads
        %from excel sheet
        xlRange = 'D35';
        xlswrite(filename,A_y(i),sheet,xlRange);

        %FL
        xlRange = 'H23';
        FL = xlsread(filename,sheet,xlRange)*9.81;

        %FR
        xlRange = 'I23';
        FR = xlsread(filename,sheet,xlRange)*9.81;

        %RL
        xlRange = 'H24';
        RL = xlsread(filename,sheet,xlRange)*9.81;

        %RR
        xlRange = 'I24';
        RR = xlsread(filename,sheet,xlRange)*9.81;


        %Calculate Fy from Pacejka Model
        FyFL = h.CalculateFy(FL,SF(i),0,0,11.176,2,coef);
        FyFR = h.CalculateFy(FR,SF(i),0,0,11.176,2,coef);

        FyRL = h.CalculateFy(RL,SR,0,0,11.176,2,coef);
        FyRR = h.CalculateFy(RR,SR,0,0,11.176,2,coef);

        %Calculate new lateral acceleration
        newA_y = (FyFL + FyFR + FyRL + FyRR)/weight;

        %Check for convergence
        %difference between A_y and newA_y is <2%
        per_diff = abs(A_y(i) - newA_y)/((A_y(i) + newA_y)/2);

        if per_diff < 2
            converges = true;
        else
            A_y(i) = newA_y;
        end

    end

    % Calculate Yaw Moment
    FyFront = FyFL + FyFR;
    FyRear = FyRL + FyRR;
    YM(i) = (FyFront * a) - (FyRear * b);

    converges = false;
end


%add (A_y, YM) to arrary array[N A_y]

% plot array
% hold on

%change beta for next sweep

%for each delta, do a beta sweep and plot on a graph

%Set corner G's to 0 in WT spread sheet

%Get FL FR RL RR static loads from excel sheet

%Loop
%Calculate Fy from Pacejka Model

%Calculate lateral acceleration
%   A_y = (FyFL + FyFR + FyRL + FyRR)/car mass;

%Calculate weight transfer
%Set G's to "A-y" in WT spread sheet Get FL FR RL RR dynamic loads
%from excel sheet

%Calculate Fy from Pacejka Model

%Calculate new lateral acceleration
%   newA_y = (FyFL + FyFR + FyRL + FyRR)/car mass;

%Check for convergence
%difference between A_y and newA_y is <2%

%   loop finished
%  A_y = newA_y;

%Calculate Yaw Moment
%   FyFront = FyFL + FyFR;
%   FyRear = FyRL + FyRR;
%   YM = (FyFront * a) - (FyRear * b);

%add (A_y, YM) to arrary array[N A_y]

%plot array
%hold on

%change delta for next sweep
