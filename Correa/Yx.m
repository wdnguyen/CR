function d = Yx(y,x,Z,dataM)
    Dym = @(y) (dataM(y) - Z(y,4))/(Z(y,2) - Z(y,4));
    Dyx = @(y,x) (Z(y,x) - Z(y,4))/(Z(y,2) - Z(y,4));

    if x == 5
        d = Dym(y);
    else
        d = Dyx(y,x);
    end
end