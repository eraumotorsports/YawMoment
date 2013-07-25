function [A_y, YM] = CalculateYM(mode, h, A_y, cp, SF, SR, fcamber, rcamber, coef)

    for i = 1:13

        converges = false;

        while converges == false

            %Calculate weight transfer
            [ FL,FR,RL,RR ] = wt( A_y(i), cp );

            %Calculate Fy from Pacejka Model
            FyFL = h.CalculateFy(FL,SF(i),0,fcamber,11.176,2,coef);
            FyFR = h.CalculateFy(FR,SF(i),0,fcamber,11.176,2,coef);

            if mode == 0
                FyRL = h.CalculateFy(RL,SR,0,rcamber,11.176,2,coef);
                FyRR = h.CalculateFy(RR,SR,0,rcamber,11.176,2,coef);
            end
            
            if mode == 1
                FyRL = h.CalculateFy(RL,SR(i),0,rcamber,11.176,2,coef);
                FyRR = h.CalculateFy(RR,SR(i),0,rcamber,11.176,2,coef);
            end

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

end