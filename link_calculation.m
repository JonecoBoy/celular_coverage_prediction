tic
clear all
close all

% Author: Jonas Nunes 
% Universidade do Estado do Rio de Janeiro
% 2017
% www.joneco.com.br

%this script will calculate and plot the fresnel elipsoid, elevation path, received power and total loss between two radio links.
%based in 4 parameters, frequency, transmission power transmitter antenna gain and receiver antenna gain

% if you wish to matlab ask you all the inputs instead of typing direct to
% de code, uncomment the next 4 lines and comment the ones that is setting
% the parameters
%f = input('Enter a Frequency Value GHz:');
%pt = input('Ente The Transmission Power in W');
%gt_db = input('Enter the transmitter atenna gain in dB:');
%gr_db = input('Enter the receiver atenna gain in dB:');



f = 6.5 %simulating the frequency of a milimeter wave transmitter link (value in GHZ)
pt = 0.35  %Power in Watts
gt_db=42.4 %transmiter atenna gain in Db
gr_db=42.4 %receiver atenna gain in Db

lambda = 3*10^8/(f*10^9) %wave lenght calculation

%converting dB
gt=10^(gt_db/10);
gr=10^(gr_db/10);

%latlong limits of the map
latlim = [-21 -20.5];
lonlim = [-52 -51.5];

%resolution of the elevation map, as bigger as the number is,more points
%will be calculated and the script will last longer
samples = 1;

%path where the  dted file is
dtedPath = 'C:\Users\Joneco\Documents\Uerj\prediction\s21_w052_1arc_v3.dt2'
[Z,refvec] = dted(dtedPath,samples,latlim,lonlim);



%ploting the map of the desired area
lat1 = -20.98516667;
lon1 = -51.83861111;
%links latitude and longitudes
latlink = [-20.74616667 lat1];
lonlink = [-51.66444444 lon1];

figure

%DTED file data as input to generate the axes and project the region boundaries for a given regin in the world.
worldmap(Z,refvec);
%project and displays the latitude and longitude vectors on the axes.
geoshow(Z,refvec,'DisplayType','surface');%projeta e mostra os vetores de latidues e longitude nos eixos.
view(3)
axis normal
tightmap
alpha(1)
demcmap(double(Z));%elevation colormap
contourm(double(Z),refvec,[0 0],'Color','black');%2d boundaries
colorbar



[z,rng,lat,lon] = mapprofile(double(Z),refvec,latlink,lonlink);%exporting the elevation data of the map
plot3m(lat,lon,z,'w','LineWidth', 3);%plotting distance between the two links

altTx=3;
altRX=3;

z(1) = z(1)+altTx;
z(end) = z(end)+ altRX;
alt1 = z(1);
alt2 = z(end);

%3d contour plot under surface plot
figure;
 % important to remove the lines. If your dataset is too dense, the thickness of the outer line of
 %each data in Z will make all your 3d elevation plot black
surfc(double(Z),'LineStyle','none');
colormap(flipud(autumn));
colorbar 
hold on
plot3(183,242,z(1), 'ro');

% terrain profile
figure,plot(deg2km(rng),z,'r');
ylabel('Altitude(Meter)');
xlabel('Distance(Km)');
hold on
plot(deg2km([rng(1) rng(end)]), [alt1 alt2]);%plotagem da visada direta onde liga 2 pontos no mapa entre tx e rx
title('Elevation Profile');
xlabel 'Distânce (Km)';
ylabel 'Elevation/Altitude (M)';
hold on


%Fresnel Ellipsoid
rng_km = deg2km(rng);
distance = rng_km(end)*1000; %distance total em metros
    % Direct Wave calculation
    b = z(1);
    m= (z(end)-z(1))/(rng_km(end)-rng_km(1));
% vector for upper and bottom fresnel zone limits
len = length(rng_km);
fresnel_superior = zeros(len,1);
fresnel_bottom = zeros(len,1);


%fresnel calculation
for i=1:length(rng_km)
    d1 = rng_km(i)*1000;
    d2 = distance - d1;
    ro = sqrt((d1*d2*3e8)/(distance*f*10^9));
    hv = m*rng_km(i)+b;
    fresnel_superior(i,1) = hv+ro;
    fresnel_bottom(i,1) = hv-ro;
end

%plotting upper elipsoid segment
plot(rng_km,fresnel_superior,'Color','g');
hold on
%plotting bottom elipsoid segment
plot(rng_km,fresnel_bottom,'Color','g');

%direct path between the two links
figure
plot(lonlim,latlim,'.k','MarkerSize',10)
hold on
plot(lonlink,latlink,'.r','MarkerSize',40)
hold on
plot(lonlink,latlink,'g','LineWidth', 3)
hold on
%plotting the google map background
plot_google_map %edit this script with your maps parameters like scale and lat/long limits



%diffraction loss calculate for the path using Epstein-Peterson model
diffraction_loss = epstein_peterson(rng_km,z,f);

for k=1:length(rng_km)
       a0(k)=((4*pi*rng_km(k)*1000)/lambda)^2;
       a0_db(k) = 10*log10(a0(k));
       pr(k) = pt*gt*gr/a0(k);
       pr_dbm(k) = 10*log10(pr(k)) +30;
       pr_dbm_total(k) = pr_dbm(k)-diffraction_loss;
end

%received power
figure;
plot(rng_km,pr_dbm_total);title 'Received Power X Distance'
xlabel('Distance (Km)');ylabel('Power (dBm)')
figure;
%total loss
plot(rng_km,a0_db-diffraction_loss);title 'Total Loss X Distância'
xlabel('Distance (Km)');ylabel('Loss (dB)')

    
toc
