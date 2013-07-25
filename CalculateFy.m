function [FyFL, FyFR, FyRL, FyRR] = CalculateFy(mode, h, FL, FR, RL, RR, SF, fcamber, rcamber, coef)

    for i = 1:13
        FyFL(i) = h.CalculateFy(FL,SF(i),0,fcamber,11.176,2,coef);
        FyFR(i) = h.CalculateFy(FR,SF(i),0,fcamber,11.176,2,coef);
        
        if mode == 1
            FyRL(i) = h.CalculateFy(RL,SR(i),0,rcamber,11.176,2,coef);
            FyRR(i) = h.CalculateFy(RR,SR(i),0,rcamber,11.176,2,coef);
        end
    end
    
    if mode == 0
        FyRL = h.CalculateFy(RL,SR,0,rcamber,11.176,2,coef);
        FyRR = h.CalculateFy(RR,SR,0,rcamber,11.176,2,coef);
    end
end