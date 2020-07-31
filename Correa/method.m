clear, clc;
format short;
%% Data
%% DATA reads the data.csv file with the input information
DATA = csvread('data.csv');

% Ms
Z = [DATA(:,1:3), ones(5,1)];
Z = transpose(Z);
dataM = Z(:,end);
Z = Z(:, 1:end-1);

% Variance
vZ = transpose(DATA(:,4:6)).^(2);

% Sample QTY
nZ = transpose(DATA(:,7:9));

%% Compute the fractions of sources (A,B,C,D) contribution to the mixture (M)(Eq. 2 and implicitly from Eq. (3)
% x in {A,B,C,D,M} = {1,2,3,4,5}
% y in {delta,lambda,phi} = {1,2,3}
f = zeros(4,1);
DYx = @(y,x) Yx(y,x, Z, dataM);

Num = (DYx(1,5)-DYx(2,5))*(DYx(3,3)-DYx(1,3)) - (DYx(1,3)-DYx(2,3))*(DYx(3,5)-DYx(1,5));
Den = (DYx(1,1)-DYx(2,1))*(DYx(3,3)-DYx(1,3)) - (DYx(1,3)-DYx(2,3))*(DYx(3,1)-DYx(1,1));
f(1) =  Num/Den;
f(3) = ((DYx(1,5)-DYx(2,5))-(DYx(1,1)-DYx(2,1))*f(1))/(DYx(1,3)-DYx(2,3));
f(2) = DYx(1,5) - (DYx(1,3)*f(3) + DYx(1,1)*f(1));
f(4) = 1 - (f(1) + f(2) + f(3));

%% Compute the partial derivatives for fA, fC, fB and fD (Eq. 4 and implicitly from Eq. 5 to Eq. 8)
% x in {A,B,C,D,M} = {1,2,3,4,5}
% Y,y in {delta,lambda,phi} = {1,2,3}
%% dfAdyx, presents the partial derivative for fA (Eq. 9)
DdYzdyx = @(Y,z,y,x) dYzdyx(Y,z,y,x,Z,dataM);

dfAdyx = @(y,x) Den^(-2)*( ...
    ((DYx(2,3)-DYx(1,3))*(DdYzdyx(3,5,y,x) - DdYzdyx(1,5,y,x)) + ...
     (DYx(3,5)-DYx(1,5))*(DdYzdyx(2,3,y,x)-DdYzdyx(1,3,y,x)) - ...
     (DYx(3,3)-DYx(1,3))*(DdYzdyx(2,5,y,x)-DdYzdyx(1,5,y,x)) - ...
     (DYx(2,5)-DYx(1,5))*(DdYzdyx(3,3,y,x)-DdYzdyx(1,3,y,x)))*Den - ...
     ((DYx(2,3)-DYx(1,3))*(DdYzdyx(3,1,y,x)-DdYzdyx(1,1,y,x)) + ...
     (DYx(3,1)-DYx(1,1))*(DdYzdyx(2,3,y,x)-DdYzdyx(1,3,y,x)) - ...
     (DYx(3,3)-DYx(1,3))*(DdYzdyx(2,1,y,x)-DdYzdyx(1,1,y,x)) - ...
     (DYx(2,1)-DYx(1,1))*(DdYzdyx(3,3,y,x)-DdYzdyx(1,3,y,x)))*Num);
 
dfCdyx = @(y,x) ((DYx(1,3)-DYx(2,3))^(-2))*( ...
    ((DdYzdyx(1,5,y,x)-DdYzdyx(2,5,y,x)) - ...
    (DdYzdyx(1,1,y,x)-DdYzdyx(2,1,y,x))*f(1) - ...
    (DYx(1,1)-DYx(2,1))*dfAdyx(y,x))*(DYx(1,3)-DYx(2,3)) - ...
    (DdYzdyx(1,3,y,x)-DdYzdyx(2,3,y,x))*( ...
    (DYx(1,5)-DYx(2,5))-(DYx(1,1)-DYx(2,1))*f(1)));

dfBdyx = @(y,x) DdYzdyx(1,5,y,x) - DdYzdyx(1,3,y,x)*f(3) - ...
    DYx(1,3)*dfCdyx(y,x) - DdYzdyx(1,1,y,x)*f(1) - DYx(1,1)*dfAdyx(y,x);

dfDdyx = @(y,x) -dfCdyx(y,x)-dfBdyx(y,x)-dfAdyx(y,x);

%% Compute the variancefor each end-member fraction, fA, fB, fC and fD respectively (Eq. 10 and Eq. 13)
% x in {A,B,C,D,M} = {1,2,3,4,5}
% y in {delta,lambda,phi} = {1,2,3}
v = zeros(4,1);
for x = 1:5
    for y = 1:3
       v(1) = v(1) + (dfAdyx(y,x)^2)*vZ(y,x);
       v(2) = v(2) + (dfBdyx(y,x)^2)*vZ(y,x);
       v(3) = v(3) + (dfCdyx(y,x)^2)*vZ(y,x);
       v(4) = v(4) + (dfDdyx(y,x)^2)*vZ(y,x);
    end
end

%%  Satterthwaite degrees of freedom for each end-member fraction (Eq. 12 and Eq. 14).
% x in {A,B,C,D,M} = {1,2,3,4,5}
% y in {delta,lambda,phi} = {1,2,3}
g = zeros(4,1);
for x = 1:5
    for y = 1:3
        g(1) = g(1) + (((dfAdyx(y,x)^2)*vZ(y,x))^2)/(nZ(y,x)-1);
        g(2) = g(2) + (((dfBdyx(y,x)^2)*vZ(y,x))^2)/(nZ(y,x)-1);
        g(3) = g(3) + (((dfCdyx(y,x)^2)*vZ(y,x))^2)/(nZ(y,x)-1);
        g(4) = g(4) + (((dfDdyx(y,x)^2)*vZ(y,x))^2)/(nZ(y,x)-1);
    end
end
g = (v.^2)./g;

%% Student’s t value(two-tailed)to compute 95% confidence intervals (Walpole et al., 2017)
t = tinv(0.95,g);

%% Compute the upper and lower confidence interval limits for each end-member fraction (Eq. 15)
ulim = min(1,f + t.*sqrt(v));
llim = max(0,f - t.*sqrt(v));

%% Present results:
%% f, fractions of sources (A,B,C,D) contribution to the mixture (M),
%% g, degrees of freedom for each end-member fraction
%% ulim and llim, upper and lower confidence interval limits for each end-member fraction
f
g
ulim
llim