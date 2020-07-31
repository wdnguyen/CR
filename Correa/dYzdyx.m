function [d] = dYzdyx(Y,z,y,x,data,dataM)
    Z = [data, dataM];
    d = 0;
    if Y == y
        if x == z && (z == 1 || z == 3 || z == 5)
            d = 1;
        elseif x == 2 && z ~= 2
            d = - Yx(y,z,Z,dataM);
        elseif x == 4 && z ~= 4
            d = Yx(y,z,Z,dataM) - 1;
        end
        d = d/(Z(y,2) - Z(y,4));
    end
end