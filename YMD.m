clear
clc

%Parameters
R = 120; %radius inches
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


%Ger car parameters from Excel sheet
filename = 'WT_YMD.xlsx';
sheet = 1;

%Wheel base
wb = xlsread(filename,sheet,'D3'); %mm

%Front track
ft = xlsread(filename,sheet,'D4'); %mm

%Rear track
rt = xlsread(filename,sheet,'D5'); %mm

%Mass
mass = xlsread(filename,sheet,'D6'); %kg
weight = mass *9.81;

%Total mass distribution
md = xlsread(filename,sheet,'D7'); % %Fr

%Front non suspended mass
fnsm = xlsread(filename,sheet,'D8'); %kg

%Rear non suspended mass
rnsm = xlsread(filename,sheet,'D9'); %kg

%Total mass CG height
tmcgh = xlsread(filename,sheet,'D11'); %mm

%Front non suspended mass CG height
fnsmcgh = xlsread(filename,sheet,'D12'); %mm

%Rear non suspended mass CG height
rnsmcgh = xlsread(filename,sheet,'D13'); %mm

%Suspended mass roll inertia (ref SM CG) - Ixx
smri = xlsread(filename,sheet,'D19'); % kg.m^2

%Front spring stiffness
fss = xlsread(filename,sheet,'D20'); %N/mm

%Rear
rss = xlsread(filename,sheet,'D21'); %N/mm

%Front ARB stiffness
farbs = xlsread(filename,sheet,'D22'); %N.m/degree

%Rear ARB stiffness
rarbs = xlsread(filename,sheet,'D23'); %N.m/degree

%Front tire stiffness
fts = xlsread(filename,sheet,'D24'); %N/mm

%Rear tire stiffness
rts = xlsread(filename,sheet,'D25'); %N/mm

%Front spring motion ratio
fsmr = xlsread(filename,sheet,'D26');

%Rear spring motion ratio
rsmr = xlsread(filename,sheet,'D27');

%Front anti roll bar motion ratio
farbmr = xlsread(filename,sheet,'D28');

%Rear anti roll bar motion ratio
rarbmr = xlsread(filename,sheet,'D29');

%Front roll center
frc = xlsread(filename,sheet,'D30');

%Rear roll center
rrc = xlsread(filename,sheet,'D31');

b_mm = (md/100)*wb;
a_mm = wb-b_mm;
a = a_mm*.0393701;
b = b_mm*.0393701;


for m = 1:13
    %Set corner G's to 0 in WT spread sheet
    A_y = 0;
  
    %Get FL FR RL RR static load from excel sheet
    [ FL,FR,RL,RR ] = wt( A_y,fnsm,rnsm,mass,md,wb,tmcgh,fnsmcgh,rnsmcgh,fss,rss,fsmr,rsmr,frc,rrc,smri,ft,rt,farbs,farbmr,rarbs,rarbmr );
        
    %for each beta, do a delta sweep and plot on a graph
    
    %Calculate front slip angles (no ackerman)
    SF = (beta(m) + (a/R) - delta)*-1;
    
    %Calculate rear slip angles (no ackerman)
    SR = (beta(m) - (b/R))*-1;
    
    
    %Loop
    %Calculate Fy from Pacejka Model
    for i = 1:13
        FyFL(i) = h.CalculateFy(FL,SF(i),0,0,11.176,2,coef);
        FyFR(i) = h.CalculateFy(FR,SF(i),0,0,11.176,2,coef);
    end
    
    FyRL = h.CalculateFy(RL,SR,0,0,11.176,2,coef);
    FyRR = h.CalculateFy(RR,SR,0,0,11.176,2,coef);
    
    
    %Calculate lateral acceleration
    for i = 1:13
        A_y(i) = (FyFL(i) + FyFR(i) + FyRL + FyRR)/weight;
    end
    
    
    for i = 1:13
        
        converges = false;
        
        while converges == false
                  
            %Calculate weight transfer
            %Set G's to "A-y" in WT spread sheet Get FL FR RL RR dynamic loads
            %from excel sheet
            %A_y(i)
            
            [ FL,FR,RL,RR ] = wt( A_y(i),fnsm,rnsm,mass,md,wb,tmcgh,fnsmcgh,rnsmcgh,fss,rss,fsmr,rsmr,frc,rrc,smri,ft,rt,farbs,farbmr,rarbs,rarbmr );
            
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
    
    plot(A_y,YM)
    title('Yaw Moment Diagram')
    xlabel('Lateral Acceleration (G)')
    ylabel('Yaw Moment (Nm)')
    hold on
    
end


%for each delta, do a beta sweep and plot on a graph

for m = 1:13
    %Set corner G's to 0 in WT spread sheet
    A_y = 0;
  
    %Get FL FR RL RR static load from excel sheet
    [ FL,FR,RL,RR ] = wt( A_y,fnsm,rnsm,mass,md,wb,tmcgh,fnsmcgh,rnsmcgh,fss,rss,fsmr,rsmr,frc,rrc,smri,ft,rt,farbs,farbmr,rarbs,rarbmr );
        
    %for each beta, do a delta sweep and plot on a graph
    
    %Calculate front slip angles (no ackerman)
    SF = (beta + (a/R) - delta(m))*-1;
    
    %Calculate rear slip angles (no ackerman)
    SR = (beta - (b/R))*-1;
    
    
    %Loop
    %Calculate Fy from Pacejka Model
    for i = 1:13
        FyFL(i) = h.CalculateFy(FL,SF(i),0,0,11.176,2,coef);
        FyFR(i) = h.CalculateFy(FR,SF(i),0,0,11.176,2,coef);
        FyRL(i) = h.CalculateFy(RL,SR(i),0,0,11.176,2,coef);
        FyRR(i) = h.CalculateFy(RR,SR(i),0,0,11.176,2,coef);
    end
    

    
    
    %Calculate lateral acceleration
    for i = 1:13
        A_y(i) = (FyFL(i) + FyFR(i) + FyRL(i) + FyRR(i))/weight;
    end
    
    
    for i = 1:13
        
        converges = false;
        
        while converges == false
                  
            %Calculate weight transfer
            [ FL,FR,RL,RR ] = wt( A_y(i),fnsm,rnsm,mass,md,wb,tmcgh,fnsmcgh,rnsmcgh,fss,rss,fsmr,rsmr,frc,rrc,smri,ft,rt,farbs,farbmr,rarbs,rarbmr );
            
            %Calculate Fy from Pacejka Model
            FyFL = h.CalculateFy(FL,SF(i),0,0,11.176,2,coef);
            FyFR = h.CalculateFy(FR,SF(i),0,0,11.176,2,coef);
            
            FyRL = h.CalculateFy(RL,SR(i),0,0,11.176,2,coef);
            FyRR = h.CalculateFy(RR,SR(i),0,0,11.176,2,coef);
            
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
    
    plot(A_y,YM)
    title('Yaw Moment Diagram')
    xlabel('Lateral Acceleration (G)')
    ylabel('Yaw Moment (Nm)')
    hold on
    
end