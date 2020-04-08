%% Calculation of Solute Masses (mg) From ICPMS Over 48-hour Data Slam (Costa Rica) from Instantaneous Mass Fluxes
% User: William Nguyen
% Last updated: February 21, 2020

% Files needed: up_mgs.xlsx, down_mgs.xlsx [these are the upstream and downstream files containing
% mass fluxes predetermined after taking the product of concentration (mg/L to mg/m3) and
% flow (m3/L)]

%% Close all windows, clear workspace
close all
clear all
clc 

%% Change directory
addpath /Users/williamnguyen/Dropbox/Nguyen_CostaRica % this is where you put the destination path of the adcp_raw.xlsx (like where it is in your computer)

%% Upstream

up = readtable('up_icpms.csv','TreatAsEmpty',{'.','NA'}) % this will import your data and treat NA's as empty and not mess up the column floats
% read more https://www.mathworks.com/help/matlab/matlab_prog/clean-messy-and-missing-data-in-tables.html

time = up{:,27}; % seconds column

% Assigning vectors for each solute
Mo = up{:,3};
Cd = up{:,4};
Sb = up{:,5};
Pb = up{:,6};
U = up{:,7};
Al = up{:,8};
Si = up{:,9};
P = up{:,10};
S = up{:,11};
Ca = up{:,12};
Cr = up{:,13};
Mn = up{:,14};
Fe = up{:,15};
Co = up{:,16};
Ni = up{:,17};
Cu = up{:,18};
Ti = up{:,19};
Zn = up{:,20};
B = up{:,21};
Sr = up{:,22};
K = up{:,23};
As = up{:,24};
Na = up{:,25};
Mg = up{:,26};

Mo_mg = trapz(time, Mo);
Cd_mg = trapz(time, Cd);
Sb_mg = trapz(time, Sb);
Pb_mg = trapz(time, Pb);
U_mg = trapz(time, U);
Al_mg = trapz(time, Al);
Si_mg = trapz(time, Si);
P_mg = trapz(time, P);
S_mg = trapz(time, S);
Ca_mg = trapz(time, Ca);
Cr_mg = trapz(time, Cr);
Mn_mg = trapz(time, Mn);
Fe_mg = trapz(time, Fe);
Co_mg = trapz(time, Co);
Ni_mg = trapz(time, Ni);
Cu_mg = trapz(time, Cu);
Ti_mg = trapz(time, Ti);
Zn_mg = trapz(time, Zn);
B_mg = trapz(time, B);
Sr_mg = trapz(time, Sr);
K_mg = trapz(time, K);
As_mg = trapz(time, As);
Na_mg = trapz(time, Na);
Mg_mg = trapz(time, Mg);

% Putting it into a pretty table
T_up=table(Mo_mg, Cd_mg, Sb_mg, Pb_mg, U_mg, Al_mg, Si_mg, P_mg, S_mg, Ca_mg, ...
    Cr_mg, Mn_mg, Fe_mg, Co_mg, Ni_mg, Cu_mg, Ti_mg, Zn_mg, B_mg, Sr_mg, K_mg, As_mg, Na_mg, Mg_mg)

% Assigning table to an Excel sheet
filename = 'up_icpms_mg_total.xlsx';
writetable(T_up,filename,'Sheet',1,'Range','A1')


%% Downstream 

close all
clear all
clc 

up = readtable('down_icpms.csv','TreatAsEmpty',{'.','NA'}) % this will import your data and treat NA's as empty and not mess up the column floats
% read more https://www.mathworks.com/help/matlab/matlab_prog/clean-messy-and-missing-data-in-tables.html

time = up{:,27}; % seconds column

% Assigning vectors for each solute
Mo = up{:,3};
Cd = up{:,4};
Sb = up{:,5};
Pb = up{:,6};
U = up{:,7};
Al = up{:,8};
Si = up{:,9};
P = up{:,10};
S = up{:,11};
Ca = up{:,12};
Cr = up{:,13};
Mn = up{:,14};
Fe = up{:,15};
Co = up{:,16};
Ni = up{:,17};
Cu = up{:,18};
Ti = up{:,19};
Zn = up{:,20};
B = up{:,21};
Sr = up{:,22};
K = up{:,23};
As = up{:,24};
Na = up{:,25};
Mg = up{:,26};

Mo_mg = trapz(time, Mo);
Cd_mg = trapz(time, Cd);
Sb_mg = trapz(time, Sb);
Pb_mg = trapz(time, Pb);
U_mg = trapz(time, U);
Al_mg = trapz(time, Al);
Si_mg = trapz(time, Si);
P_mg = trapz(time, P);
S_mg = trapz(time, S);
Ca_mg = trapz(time, Ca);
Cr_mg = trapz(time, Cr);
Mn_mg = trapz(time, Mn);
Fe_mg = trapz(time, Fe);
Co_mg = trapz(time, Co);
Ni_mg = trapz(time, Ni);
Cu_mg = trapz(time, Cu);
Ti_mg = trapz(time, Ti);
Zn_mg = trapz(time, Zn);
B_mg = trapz(time, B);
Sr_mg = trapz(time, Sr);
K_mg = trapz(time, K);
As_mg = trapz(time, As);
Na_mg = trapz(time, Na);
Mg_mg = trapz(time, Mg);

% Putting it into a pretty table
T_down=table(Mo_mg, Cd_mg, Sb_mg, Pb_mg, U_mg, Al_mg, Si_mg, P_mg, S_mg, Ca_mg, ...
    Cr_mg, Mn_mg, Fe_mg, Co_mg, Ni_mg, Cu_mg, Ti_mg, Zn_mg, B_mg, Sr_mg, K_mg, As_mg, Na_mg, Mg_mg)

% Assigning table to an Excel sheet
filename = 'down_icpms_mg_total.xlsx';
writetable(T_down,filename,'Sheet',1,'Range','A1')

