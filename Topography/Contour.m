% William Nguyen
% Editing Peter Knappett's code
% Last updated 09/25/2020

% This script contours synoptic manual water levels from monitoring wells
% within the same aquifer

clear

% Determine global values for script
msize=40; % sets default marker size
fsize=16; % sets default font size
lsize=2; % sets default line widths
spacing=1; % spacing of grid cells for contouring in meters
MAX=5.7; % maximum F concentration for contour color bar
yshift=1; % shift labels x meters north
xshift=1; % shift labels x meters east
n=20; % number of contours
step=10; % spacing between contours
cmap='jet';
themec = [0.11 0.58 0.08; 1 0.71 0.1; 0.67 0.06 0.06; 0.06 0.22 0.67];

Xcol=2; % column where x coordinate is found
Ycol=3; % column where y coordinate is found
Zcol=4; % column where water level depth is found

% Read in data into Matrices
%[Coord,~,~]=xlsread('C:\Users\knappett\Dropbox\A Texas A&M\Research\1 Projects\Active - Costa Rica\Spatial Data\Topography\To Matlab\All_Points_HM.xlsx');
[Coord,~,~]=xlsread('C:\Users\wdn266\Dropbox\CR\Topography\All_Points_HM.xlsx');

% reads in total station x,y coordinates as matrix (numbers only)
%[~,~,ID]=xlsread('C:\Users\knappett\Dropbox\A Texas A&M\Research\1 Projects\Active - Costa Rica\Spatial Data\Topography\To Matlab\All_Points_HM.xlsx'); 
[~,~,ID]=xlsread('C:\Users\wdn266\Dropbox\CR\Topography\All_Points_HM.xlsx'); 

% reads in total station x,y coordinates with well IDs as Cell Array (treats data as text strings)

% Read in data into Matrices
%[Coord2,~,~]=xlsread('C:\Users\knappett\Dropbox\A Texas A&M\Research\1 Projects\Active - Costa Rica\Spatial Data\Topography\To Matlab\Andrea_stuff.xlsx');
[Coord2,~,~]=xlsread('C:\Users\wdn266\Dropbox\CR\Topography\Andrea_stuff.xlsx');


% reads in total station x,y coordinates as matrix (numbers only)
%[~,~,ID2]=xlsread('C:\Users\knappett\Dropbox\A Texas A&M\Research\1 Projects\Active - Costa Rica\Spatial Data\Topography\To Matlab\Andrea_stuff.xlsx'); 
[~,~,ID2]=xlsread('C:\Users\wdn266\Dropbox\CR\Topography\Andrea_stuff.xlsx'); 

% reads in total station x,y coordinates with well IDs as Cell Array (treats data as text strings)

% Read in data into Matrices
%[Coord3,~,~]=xlsread('C:\Users\knappett\Dropbox\A Texas A&M\Research\1 Projects\Active - Costa Rica\Spatial Data\Topography\To Matlab\2018_Points.xlsx');
[Coord3,~,~]=xlsread('C:\Users\wdn266\Dropbox\CR\Topography\Paper_2019_Points_Renamed.xlsx');

% reads in total station x,y coordinates as matrix (numbers only)
%[~,~,ID3]=xlsread('C:\Users\knappett\Dropbox\A Texas A&M\Research\1 Projects\Active - Costa Rica\Spatial Data\Topography\To Matlab\2018_Points.xlsx'); 
[~,~,ID3]=xlsread('C:\Users\wdn266\Dropbox\CR\Topography\Paper_2019_Points_Renamed.xlsx'); 

%%% making array for groupings:
gr = ["Soil";"Soil";"Soil";"Soil";"Soil";"Spring";"Spring";"Spring";"Spring";"Spring";"Spring";"US";"DS";"Soil";"Spring"];

% reads in total station x,y coordinates with well IDs as Cell Array (treats data as text strings)

minX=min(Coord(:,Xcol)); % sets left side extent of contour plot
maxX=max(Coord(:,Xcol)); % sets right side extent
minY=min(Coord(:,Ycol)); % sets lower extent
maxY=max(Coord(:,Ycol)); % sets upper extent

%minZ=round(min(Coord(:,Zcol))); % sets lower extent
minZ=-10;
maxZ=round(max(Coord(:,Ycol))); % sets upper extent
levels = minZ:step:maxZ;

figure(1)
% colored surface (using the max spatial extents from the manual water level
% measurements assumes those measurements are at least as spatially
% extensive as those locations where pressure transducers are installed
[xi,yi]=meshgrid(minX:spacing:maxX, minY:spacing:maxY); % this creates an empty grid that 
% extends between minX and maxX, and minY and maxY every 1 m. 
% This means the contouring is performed using 1x1 m spatial resolution.
zi=griddata(Coord(:,Xcol), Coord(:,Ycol), Coord(:,Zcol), xi, yi,'natural'); % this populates the 

% grid with actual x,y,z data points, where z is water level (mad)

[c h] = contourf(xi,yi,zi,levels,'k-','ShowText','on'); % this calculates the values in each gridded cell, 
% interpolating between known x,y,z nodes.
% h is the plot handle. Produces a plot with contours that are filled in
% with colors
clabel(c,h)
colormap(flipud(gray))
% colormap(flipud(bone))

brighten(0.5)
axis auto

b=7; % white border thickness around contour plot
axis([minX-50 maxX+b minY-50 maxY+b]);

xlabel('X (m)','FontSize',fsize); % labels x axis
ylabel('Y (m)','FontSize',fsize); % labels y axis
xt = get(gca, 'XTick');
set(gca, 'FontSize', fsize)

%MIN=min(min(Coord(:,Zcol)), min(NewCoord(:,Zcol)));
%MAX=max(max(Coord(:,Zcol)), max(NewCoord(:,Zcol)));
%hold on
%scatter(Coord(:,Xcol),Coord(:,Ycol),'ko','filled'); % plots symbols on a
%scatter plot showing positions of all the points used to make the
%elevation contour map
%hold on
%scatter(Coord2(:,3),Coord2(:,4),'ro','filled'); % plots symbols on a scatter plot showing positions of Andrea's points
hold on
% scatter(Coord3(:,3),Coord3(:,4),msize,'ko','filled'); % plots locations of points of interest for 2018 project
gscatter(Coord3(:,3),Coord3(:,4), gr, themec, '.', msize/2) 
hold on

%for j=1:length(ID) % starts a loop to label wells used in contour plot.
%    g=text(ID{j,Xcol}+xshift,ID{j,Ycol}+yshift,ID(j,1)); % shifts labels 1.5 m to left 
%    set(g,'Color','k','FontSize',fsize-4);
    % and assigns the appropriate ID name from the cell array "ID". 
    % "i+1" is used because, unlike the matrix Coord, the cell array contains 
    % all text, including the column headers
%end

%for j=2:length(ID2) % starts a loop to label wells used in contour plot.
%    g=text(ID2{j,5}+xshift,ID2{j,6}+yshift,ID2{j,4}); % shifts labels 1.5 m to left 
%    set(g,'Color','k','FontSize',fsize-4);
    % and assigns the appropriate ID name from the cell array "ID". 
    % "i+1" is used because, unlike the matrix Coord, the cell array contains 
    % all text, including the column headers
%end


% for j=2:length(ID3) % starts a loop to label wells used in contour plot.
%     g=text(ID3{j,3}+xshift,ID3{j,4}+yshift,ID3{j,2}); % shifts labels 1.5 m to left 
%     set(g,'Color','k','FontSize',fsize-4);
%     % and assigns the appropriate ID name from the cell array "ID". 
%     % "i+1" is used because, unlike the matrix Coord, the cell array contains 
%     % all text, including the column headers
% end


hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clipping

figure(2)

minX=-125; % sets left side extent of contour plot
maxX=0; % sets right side extent
minY=-25; % sets lower extent
maxY=50; % sets upper extent

[xi,yi]=meshgrid(minX:spacing*0.5:maxX, minY:spacing*0.5:maxY); % this creates an empty grid that 
% extends between minX and maxX, and minY and maxY every 1 m. 
% This means the contouring is performed using 1x1 m spatial resolution.
zi=griddata(Coord(:,Xcol), Coord(:,Ycol), Coord(:,Zcol), xi, yi,'natural'); % this populates the 

% grid with actual x,y,z data points, where z is water level (mad)

[c h] = contourf(xi,yi,zi,levels,'k-','ShowText','on'); % this calculates the values in each gridded cell, 
% interpolating between known x,y,z nodes.
% h is the plot handle. Produces a plot with contours that are filled in
% with colors
clabel(c,h)
colormap(flipud(gray))
% colormap(flipud(bone))

brighten(0.5)
axis auto

b=7; % white border thickness around contour plot
axis([minX-b maxX+b minY-b maxY+b]);

xlabel('X (m)','FontSize',fsize); % labels x axis
ylabel('Y (m)','FontSize',fsize); % labels y axis
xt = get(gca, 'XTick');
set(gca, 'FontSize', fsize)

%MIN=min(min(Coord(:,Zcol)), min(NewCoord(:,Zcol)));
%MAX=max(max(Coord(:,Zcol)), max(NewCoord(:,Zcol)));
%hold on
%scatter(Coord(:,Xcol),Coord(:,Ycol),'ko','filled'); % plots symbols on a
%scatter plot showing positions of all the points used to make the
%elevation contour map
%hold on
%scatter(Coord2(:,3),Coord2(:,4),'ro','filled'); % plots symbols on a scatter plot showing positions of Andrea's points
hold on
% scatter(Coord3(:,3),Coord3(:,4),msize,'ko','filled'); % plots locations of points of interest for 2018 project
gscatter(Coord3(:,3),Coord3(:,4), gr, themec, '.', msize/2, 'off') 

hold on


for j=2:length(ID3) % starts a loop to label wells used in contour plot.
    g=text(ID3{j,3}+xshift,ID3{j,4}+yshift,ID3{j,2}); % shifts labels 1.5 m to left 
    set(g,'Color','k','FontSize',fsize-4);
    % and assigns the appropriate ID name from the cell array "ID". 
    % "i+1" is used because, unlike the matrix Coord, the cell array contains 
    % all text, including the column headers
end
