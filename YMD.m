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

    %Loop
    %Calculate Fy from Pacejka Model
    for i = 1:13
        FyFL(i) = h.CalculateFy(FL,SF(i),0,fcamber,11.176,2,coef);
        FyFR(i) = h.CalculateFy(FR,SF(i),0,fcamber,11.176,2,coef);
    end

    FyRL = h.CalculateFy(RL,SR,0,rcamber,11.176,2,coef);
    FyRR = h.CalculateFy(RR,SR,0,rcamber,11.176,2,coef);


    %Calculate lateral acceleration
    for i = 1:13
        A_y(i) = (FyFL(i) + FyFR(i) + FyRL + FyRR) / cp.Weight;
    end

    for i = 1:13

        converges = false;

        while converges == false

            %Calculate weight transfer
            %Set G's to "A-y" in WT spread sheet Get FL FR RL RR dynamic loads
            %from excel sheet
            %A_y(i)

            [ FL,FR,RL,RR ] = wt( A_y(i), cp );

            %Calculate Fy from Pacejka Model
            FyFL = h.CalculateFy(FL,SF(i),0,fcamber,11.176,2,coef);
            FyFR = h.CalculateFy(FR,SF(i),0,fcamber,11.176,2,coef);

            FyRL = h.CalculateFy(RL,SR,0,rcamber,11.176,2,coef);
            FyRR = h.CalculateFy(RR,SR,0,rcamber,11.176,2,coef);

            %Calculate new lateral acceleration
            newA_y = (FyFL + FyFR + FyRL + FyRR) / cp.Weight;

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

    plot(A_y,YM)
    title('Yaw Moment Diagram')
    xlabel('Lateral Acceleration (G)')
    ylabel('Yaw Moment (Nm)')
    hold on

end

%% For each delta, do a beta sweep and plot on a graph
for m = 1:13
    %Set corner G's to 0 in WT spread sheet
    A_y = 0;

    %Get FL FR RL RR static load from excel sheet
    [ FL,FR,RL,RR ] = wt( A_y, cp);

    %Calculate front slip angles (no ackerman)
    SF = (beta + (a/R) - delta(m))*-1;

    %Calculate rear slip angles (no ackerman)
    SR = (beta - (b/R))*-1;


    %Loop
    %Calculate Fy from Pacejka Model
    for i = 1:13
        FyFL(i) = h.CalculateFy(FL,SF(i),0,fcamber,11.176,2,coef);
        FyFR(i) = h.CalculateFy(FR,SF(i),0,fcamber,11.176,2,coef);
        FyRL(i) = h.CalculateFy(RL,SR(i),0,rcamber,11.176,2,coef);
        FyRR(i) = h.CalculateFy(RR,SR(i),0,rcamber,11.176,2,coef);
    end

    %Calculate lateral acceleration
    for i = 1:13
        A_y(i) = (FyFL(i) + FyFR(i) + FyRL(i) + FyRR(i)) / cp.Weight;
    end

    for i = 1:13

        converges = false;

        while converges == false

            %Calculate weight transfer
            [ FL,FR,RL,RR ] = wt( A_y(i), cp);

            %Calculate Fy from Pacejka Model
            FyFL = h.CalculateFy(FL,SF(i),0,fcamber,11.176,2,coef);
            FyFR = h.CalculateFy(FR,SF(i),0,fcamber,11.176,2,coef);

            FyRL = h.CalculateFy(RL,SR(i),0,rcamber,11.176,2,coef);
            FyRR = h.CalculateFy(RR,SR(i),0,rcamber,11.176,2,coef);

            %Calculate new lateral acceleration
            newA_y = (FyFL + FyFR + FyRL + FyRR) / cp.Weight;

            %Check for convergence
            %difference between A_y and newA_y is <2%
            per_diff = abs(A_y(i) - newA_y)/((A_y(i) + newA_y) / 2);

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

    plot(A_y,YM)
    title('Yaw Moment Diagram')
    xlabel('Lateral Acceleration (G)')
    ylabel('Yaw Moment (Nm)')
    hold on

end

% Plot combined graphs
plot(A_y,YM)