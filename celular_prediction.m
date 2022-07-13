tic 

clear all
close all


% if you wish to matlab ask you all the inputs instead of typing direct to
% de code, uncomment the next 4 lines and comment the ones that is setting
% the parameters
%f = input('Enter a Frequency Value GHz:');
%pt = input('Ente The Transmission Power in W');
%gt_db = input('Enter the transmitter atenna gain in dB:');
%gr_db = input('Enter the receiver atenna gain in dB:');
f = 2.6 % Enter a frequency value in GHz:
pt = 20 % Enter the transmitter power in W (common value for cellphoen radios is 20W to 40W)
gt_db=16 %transmiter atenna gain in Db
gr_db=0  %r atenna gain in Db  


lambda = 3*10^8/(f*10^9) %wave lenght calculation


%converting dB
gt=10^(gt_db/10);   
gr=10^(gr_db/10);

%latlong limits of the map
latlim = [-21 -20.5];
lonlim = [-52 -51.5];

%resolution of the elevation map, as bigger as the number is,more points
%will be calculated and the script will last longer
samples = 15;

%path where the  dted file is
dtedPath = 'C:\Users\Joneco\Documents\Uerj\prediction\s21_w052_1arc_v3.dt2'
%Elevation and reference vector from a dted file cropped by the latlong
%limit specified above
[Z,refvec] = dted(dtedPath,samples,latlim,lonlim);

%getting all latitude info from the dted
for i = 1:size(Z,1);
[latitude(i) temp] = setltln(Z,refvec,i,1); %setltln vai retornar a latlong da posicao i,1 na matrix Z
end

%getting all longitud info from the dted
for j = 1:size(Z,1);
[temp longitude(j)] = setltln(Z,refvec,1,j); %setltln vai retornar a latlong da posicao i,1 na matrix Z
end



for i= 1:size(Z,1);
    for j = 1:size(Z,1);
        
%Will plot the desired region map
lat1 = latitude(i);
lon1 = longitude(j);

%links latitude and longitudes
latlink = [-20.74616667 lat1]; %first parameter is a fixed latitude the represents the latitude of the transmitter
lonlink = [-51.66444444 lon1]; %first parameter is a fixed latitude the represents the longitude of the transmitter
        
[z,rng,lat,lon] = mapprofile(double(Z),refvec,latlink,lonlink);%exports the elevation map data

rng_km = deg2km(rng); % converting spherical distance data from the mapprofile to kilometer

% path loss based in the epstein peterson
% model for diffraction losses for a multiple obstacles path
epstein_loss = epstein_peterson(rng_km,z,f);

       distance(i,j) = rng_km(end);
       a0(i,j)=(((4*pi*rng_km(end)*1000)/lambda)^2);
       a0_db(i,j) = 10*log10(a0(i,j));
       pr(i,j) = pt*gt*gr/a0(i,j);
       pr_dbm(i,j) = 10*log10(pr(i,j)) +30;
       pr_dbm_total(i,j) = pr_dbm(i,j)-epstein_loss;

    end
end


%colormap of the signal power considering a isotropic antena in the free
%space (no difraction loss applied) (no obstacles/ no elevation terrain)
figure;

%DTED file data as input to generate the axes and project the region boundaries for a given regin in the world.
worldmap(pr_dbm,refvec);

geoshow(pr_dbm,refvec,'DisplayType','texturemap');%project and displays the latitude and longitude vectors on the axes.
alpha(1)
demcmap(double(pr_dbm));%sets the colormap and color axis limits based on the elevation data limits derived from input argument Z

colormap(flipud(autumn)) %change the colormap profile
caxis([-75, -45])       % defining the max and min of the colormap
colorbar                % plots the color map in figure

%colormap of the signal power considering a isotropic antena considering
%the difraction / obstacles (elevation terrain)
figure;
%DTED file data as input to generate the axes and project the region boundaries for a given regin in the world.
worldmap(pr_dbm_total,refvec);
geoshow(pr_dbm_total,refvec,'DisplayType','texturemap');%project and displays the latitude and longitude vectors on the axes.
alpha(1)
demcmap(double(pr_dbm_total));%sets the colormap and color axis limits based on the elevation data limits derived from input argument Z
contourm(double(pr_dbm_total),refvec,[0 0],'Color','black');%2D contour/boundarions of the Z grid data.
colormap(flipud(autumn)) %change the colormap profile
caxis([-105, -45]) %fixing the c axis
colorbar


%boundary lines of the signal power considering a isotropic antena in the free
%space (no difraction loss applied) (no obstacles/ no elevation terrain),
%just free space loss
figure;
worldmap(Z,refvec)
geoshow(Z,refvec,'DisplayType','texturemap')
demcmap(double(Z))
contourm(double(Z),refvec,[0 0],'Color','red')

colorbar
levelstep = -15;     %meters
[C,h]=contourm(double(pr_dbm), refvec,'LevelStep',levelstep,'Color','white','ShowText','on');

%boundary lines of the signal power considering a isotropic antena considering
%the difraction / obstacles (elevation terrain)
figure;
worldmap(Z,refvec)
geoshow(Z,refvec,'DisplayType','texturemap')
alpha(1)
demcmap(double(Z))
contourm(double(Z),refvec,[0 0],'Color','red')
colorbar
levelstep = -15;     %meters
[C,h]=contourm(double(pr_dbm_total), refvec,'LevelStep',levelstep,'Color','white','ShowText','on');



%google maps plots with boundary line
figure
plot(lonlim,latlim,'.k','MarkerSize',2)
hold on
plot_google_map % edit this script with your maps parameters like scale and lat/long limits
hold on
[C,h]=contourm(double(pr_dbm), refvec,'LevelStep',levelstep,'Color','white','ShowText','on');

%google maps plots with boundary line
figure
plot(lonlim,latlim,'.k','MarkerSize',2)
hold on
plot_google_map % edit this script with your maps parameters like scale and lat/long limits
hold on
[C,h]=contourm(double(pr_dbm_total), refvec,'LevelStep',levelstep,'Color','white','ShowText','on');



    
toc