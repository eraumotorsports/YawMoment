clear
clc

%Parameters
R = 120; %radius inches
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


%Ger car parameters from Excel sheet
filename = 'WT_YMD.xlsx';

cp = CarParameters;
cp = cp.LoadFromExcel(filename);

b_mm = (cp.MassDistribution / 100) * cp.WheelBase;
a_mm = cp.WheelBase - b_mm;
a = a_mm*.0393701;
b = b_mm*.0393701;

for m = 1:11
    %Set corner G's to 0 in WT spread sheet
    A_y = 0;
  
    %Get FL FR RL RR static load from excel sheet
    [ FL,FR,RL,RR ] = wt( A_y, cp );
        
    %for each beta, do a delta sweep and plot on a graph
    
    %Calculate front slip angles (no ackerman)
    SF = (beta(m) + (a/R) - delta)*-1;
    
    %Calculate rear slip angles (no ackerman)
    SR = (beta(m) - (b/R))*-1;
    
    
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
        A_y(i) = (FyFL(i) + FyFR(i) + FyRL + FyRR) / cp.Weight;
    end
    
    
    for i = 1:11
        
        converges = false;
        
        while converges == false
                  
            %Calculate weight transfer
            %Set G's to "A-y" in WT spread sheet Get FL FR RL RR dynamic loads
            %from excel sheet
            %A_y(i)
            
            [ FL,FR,RL,RR ] = wt( A_y(i), cp );
            
            %Calculate Fy from Pacejka Model
            FyFL = h.CalculateFy(FL,SF(i),0,0,11.176,2,coef);
            FyFR = h.CalculateFy(FR,SF(i),0,0,11.176,2,coef);
            
            FyRL = h.CalculateFy(RL,SR,0,0,11.176,2,coef);
            FyRR = h.CalculateFy(RR,SR,0,0,11.176,2,coef);
            
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


%for each delta, do a beta sweep and plot on a graph

for m = 1:11
    %Set corner G's to 0 in WT spread sheet
    A_y = 0;
  
    %Get FL FR RL RR static load from excel sheet
    [ FL,FR,RL,RR ] = wt( A_y, cp);
        
    %for each beta, do a delta sweep and plot on a graph
    
    %Calculate front slip angles (no ackerman)
    SF = (beta + (a/R) - delta(m))*-1;
    
    %Calculate rear slip angles (no ackerman)
    SR = (beta - (b/R))*-1;
    
    
    %Loop
    %Calculate Fy from Pacejka Model
    for i = 1:11
        FyFL(i) = h.CalculateFy(FL,SF(i),0,0,11.176,2,coef);
        FyFR(i) = h.CalculateFy(FR,SF(i),0,0,11.176,2,coef);
        FyRL(i) = h.CalculateFy(RL,SR(i),0,0,11.176,2,coef);
        FyRR(i) = h.CalculateFy(RR,SR(i),0,0,11.176,2,coef);
    end
    

    
    
    %Calculate lateral acceleration
    for i = 1:11
        A_y(i) = (FyFL(i) + FyFR(i) + FyRL(i) + FyRR(i)) / cp.Weight;
    end
    
    
    for i = 1:11
        
        converges = false;
        
        while converges == false
                  
            %Calculate weight transfer
            %Set G's to "A-y" in WT spread sheet Get FL FR RL RR dynamic loads
            %from excel sheet
            %A_y(i)
            
            [ FL,FR,RL,RR ] = wt( A_y(i), cp);
            
            %Calculate Fy from Pacejka Model
            FyFL = h.CalculateFy(FL,SF(i),0,0,11.176,2,coef);
            FyFR = h.CalculateFy(FR,SF(i),0,0,11.176,2,coef);
            
            FyRL = h.CalculateFy(RL,SR(i),0,0,11.176,2,coef);
            FyRR = h.CalculateFy(RR,SR(i),0,0,11.176,2,coef);
            
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
