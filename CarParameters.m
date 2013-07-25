classdef CarParameters
    properties
        WheelBase
        FrontTrack
        RearTrack
        Mass
        MassDistribution
        FrontNonSuspMass
        RearNonSuspMass
        TotalMassCGHeight
        FrontNonSuspMassCGHeight
        RearNonSuspMassCGHeight
        SuspMassRollInertia
        FrontSpringStiffness
        RearSpringStiffness
        FrontARBStiffness
        RearARBStiffness
        FrontTireStiffness
        RearTireStiffness
        FrontSpringMotionRatio
        RearSpringMotionRatio
        FrontARBMotionRatio
        RearARBMotionRatio
        FrontRollCenter
        RearRollCenter
    end
    
    properties (Dependent = true, SetAccess = private)
        Weight
    end
    
    methods
        function weight = get.Weight(CP)
            weight = CP.Mass * 9.81;
        end
        
        function CP = LoadFromExcel(CP, filepath)
            sheet = 1;

            %Wheel base
            CP.WheelBase = xlsread(filepath,sheet,'D3'); %mm

            %Front track
            CP.FrontTrack = xlsread(filepath,sheet,'D4'); %mm

            %Rear track
            CP.RearTrack = xlsread(filepath,sheet,'D5'); %mm

            %Mass
            CP.Mass = xlsread(filepath,sheet,'D6'); %kg

            %Total mass distribution
            CP.MassDistribution = xlsread(filepath,sheet,'D7'); % %Fr

            %Front non suspended mass
            CP.FrontNonSuspMass = xlsread(filepath,sheet,'D8'); %kg

            %Rear non suspended mass
            CP.RearNonSuspMass = xlsread(filepath,sheet,'D9'); %kg

            %Total mass CG height
            CP.TotalMassCGHeight = xlsread(filepath,sheet,'D11'); %mm

            %Front non suspended mass CG height
            CP.FrontNonSuspMassCGHeight = xlsread(filepath,sheet,'D12'); %mm

            %Rear non suspended mass CG height
            CP.RearNonSuspMassCGHeight = xlsread(filepath,sheet,'D13'); %mm

            %Suspended mass roll inertia (ref SM CG) - Ixx
            CP.SuspMassRollInertia = xlsread(filepath,sheet,'D19'); % kg.m^2

            %Front spring stiffness
            CP.FrontSpringStiffness = xlsread(filepath,sheet,'D20'); %N/mm

            %Rear
            CP.RearSpringStiffness = xlsread(filepath,sheet,'D21'); %N/mm

            %Front ARB stiffness
            CP.FrontARBStiffness = xlsread(filepath,sheet,'D22'); %N.m/degree

            %Rear ARB stiffness
            CP.RearARBStiffness = xlsread(filepath,sheet,'D23'); %N.m/degree

            %Front tire stiffness
            CP.FrontTireStiffness = xlsread(filepath,sheet,'D24'); %N/mm

            %Rear tire stiffness
            CP.RearTireStiffness = xlsread(filepath,sheet,'D25'); %N/mm

            %Front spring motion ratio
            CP.FrontSpringMotionRatio = xlsread(filepath,sheet,'D26');

            %Rear spring motion ratio
            CP.RearSpringMotionRatio = xlsread(filepath,sheet,'D27');

            %Front anti roll bar motion ratio
            CP.FrontARBMotionRatio = xlsread(filepath,sheet,'D28');

            %Rear anti roll bar motion ratio
            CP.RearARBMotionRatio = xlsread(filepath,sheet,'D29');

            %Front roll center
            CP.FrontRollCenter = xlsread(filepath,sheet,'D30');

            %Rear roll center
            CP.RearRollCenter = xlsread(filepath,sheet,'D31');
        end
    end
end