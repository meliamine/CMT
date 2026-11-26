% Projet CMT - PM2.5 Sofia
% Periode : janvier 2024

% Clean up the environnment of work
clear;
clc;
close all;

%% 1. Geographic boundaries and box dimensions

lat_north = 42.85;  % [°]
lat_south = 42.60;  % [°]

lon_west = 23.10;   % [°]
lon_east = 23.60;   % [°]

% Define the dimentions of our box
% Tanks to a website, we found:
width_box_sofia = 40.76 * 10^3; % [m]
height_box_sofia = 27.8 * 10^3; % [km]

fprintf('Longueur Nord-Sud : %.2f km\n', height_box_sofia);
fprintf('Longueur Est-Ouest : %.2f km\n', width_box_sofia);

% Area of the box
A_box_sofia = width_box_sofia * height_box_sofia; % [m^2]

fprintf('Surface : %.2f m^2\n', A_box_sofia);

%% 2. Import the data for January 2024

% ncdisp(file_name) --> Permet de visualiser la structure des data files,
% pour après savoir comment attribuer des valeurs aux variables

% Define the project folder
% Récupère automatiquement le chemin du dossier dans lequel se trouve le script MATLAB.
project_folder = fileparts(mfilename('fullpath'));

% Import: wind data
file_vent = fullfile(project_folder, 'data_01_2024', 'vent_01_2024.nc');

% Define wind's variables 
u10 = ncread(file_vent, 'u10');
v10 = ncread(file_vent, 'v10');
lat_wind = ncread(file_vent, 'latitude');
lon_wind = ncread(file_vent, 'longitude');
time_wind = ncread(file_vent, 'valid_time');

% Import: mixing layer height data
file_height = fullfile(project_folder, 'data_01_2024', 'hauteur_01_2024.nc');

% Define height's variable
blh = ncread(file_height, 'blh');
lat_height = ncread(file_height, 'latitude');
lon_height = ncread(file_height, 'longitude');
time_height = ncread(file_height, 'valid_time');

% Import: temperature data
file_temperature = fullfile(project_folder, 'data_01_2024', 'temperature_01_2024.nc');

% Define temperature's variables
t2m = ncread(file_temperature, 't2m');
lat_temperature = ncread(file_temperature, 'latitude');
lon_temperature = ncread(file_temperature, 'longitude');
time_temperature = ncread(file_temperature, 'valid_time');

% Import: concentration data
file_concentration_PM_25 = fullfile(project_folder, 'data_01_2024', 'PM2.5_concentration_reduced_01_2024.nc');

% Define concentration's variables
pm2p5 = ncread(file_concentration_PM_25, 'pm2p5');
lat_concentration = ncread(file_concentration_PM_25, 'lat');
lon_concentration = ncread(file_concentration_PM_25, 'lon');
time_concentration = ncread(file_concentration_PM_25, 'time');

%% 3. Data processing 

% Convert ERA5 time in second to datetime
% Explication:
% Nos data n'ont pas été prise avec la même référence de temps initiale. 
% ERA5 additionne les secondes écoulées depuis le 1 janvier 1970. 
% CAMS additionne les heures écoulé depuis le 1 janvier 2024.
% Grâce à datetime(), on peut convertir ces deux représentations en dates identiques 
% pour pouvoir comparer et associer nos données.
% De base on a des int, on transforme en double. 
% Ensuite, datetime donne la valeur de référence du début des mesures. 
% Puis, on additionne les secondes mesurée à la date de référence pour avoir la vrai
% date en heur/jour/mois/années. Et on remplace par notre nouvelle valeure.
% !!! Les deux sources possèdent 744 valeurs temporelles, avec un pas de temps identique de 1 heure. 
% Seule leur représentation initiale du temps est différente.

time_wind = datetime(1970,1,1) + seconds(double(time_wind));   
time_height = datetime(1970,1,1) + seconds(double(time_height));
time_temperature = datetime(1970,1,1) + seconds(double(time_temperature));

% Convert CAMS time in hour to datetime
time_concentration = datetime(2024,1,1) + hours(time_concentration);

% Check temporal consistency
% Explication:
% La fonction isequal compare si les deux tableaux sont égaux.
% Si oui, elle renvoie 1, sinon 0.
% C'éttait un test, pas nécessaire de le laisser dans le code
% isequal(time_wind, time_height)
% isequal(time_wind, time_temperature)
% isequal(time_wind, time_concentration)


% Geographic selection

% Select wind points inside the box
% Explication:
% La fonction find() récupère les indices des points qui respectent les conditions.
idx_lat_wind = find(lat_wind >= lat_south & lat_wind <= lat_north);
idx_lon_wind = find(lon_wind >= lon_west & lon_wind <= lon_east);

% Extract the corresponding wind data
% Explication:
% Le symbole : dans la troisième dimension permet de conserver toutes les données horaires de janvier 2024, 
% tout en sélectionnant uniquement les points géographiques situés à l'intérieur de notre boîte.
% Parce que le vent est un tableau 4x3x744, 
% avec 4 = longitude et 3 = latitudes et 744 = heures
% On va donc obtenir les valeurs de u10 et v10 dans un tableau 2x1x744

u10_box = u10(idx_lon_wind, idx_lat_wind, :);
v10_box = v10(idx_lon_wind, idx_lat_wind, :);

% Select mixing layer height inside the box
idx_lat_height = find(lat_height >= lat_south & lat_height <= lat_north);
idx_lon_height = find(lon_height >= lon_west & lon_height <= lon_east);

% Extract the corresponding mixing layer height data
blh_box = blh(idx_lon_height, idx_lat_height, :);

% Select temperature inside the box
idx_lat_temperature = find(lat_temperature >= lat_south & lat_temperature <= lat_north);
idx_lon_temperature = find(lon_temperature >= lon_west & lon_temperature <= lon_east);

% Extract the corresponding temperature data
t2m_box = t2m(idx_lon_temperature, idx_lat_temperature, :);

% Select the concentration of PM 2.5 inside the box
idx_lat_concentration = find(lat_concentration >= lat_south & lat_concentration <= lat_north);
idx_lon_concentration = find(lon_concentration >= lon_west & lon_concentration <= lon_east);

% Extract the corresponding concentration of PM 2.5 data
pm2p5_box = pm2p5(idx_lon_concentration, idx_lat_concentration, :);

% Select PM2.5 points outside each boundary
%Explication:
% Pour avoir la concentration entrant dans notre boite, on a besoin d'avoir
% les concentration de PM 2.5 en tenant compte de la direction du vent.
% Exemple: Si le vent vient de l'Ouest, nous utilisons les concentrations à l'Ouest de la boîte. 
idx_west_concentration_outside = find(lon_concentration < lon_west);
idx_east_concentration_outside = find(lon_concentration > lon_east);
idx_north_concentration_outside = find(lat_concentration > lat_north);
idx_south_concentration_outside = find(lat_concentration < lat_south);

% Extract the corresponding PM2.5 concentration data
pm2p5_west = pm2p5(idx_west_concentration_outside, idx_lat_concentration, :);
pm2p5_east = pm2p5(idx_east_concentration_outside, idx_lat_concentration, :);

pm2p5_north = pm2p5(idx_lon_concentration, idx_north_concentration_outside, :);
pm2p5_south = pm2p5(idx_lon_concentration, idx_south_concentration_outside, :);

%% 4. Parameter calculations

% Wind speed and direction u(t)

% Calculate the hourly spatial mean of wind components
% Explication:
% mean(..., [1 2])calcule la moyenne selon les dimensions longitude et latitude.
% squeeze() supprime les dimensions de taille 1.
% Parce qu'après avoir calculé la moyenne spatiale, 
% les dimensions longitude et latitude ne sont plus utiles pour notre modèle.
% On obtient donc deux vecteurs de dimensions 744x1.
u10_box_mean = squeeze(mean(u10_box, [1 2]));
v10_box_mean = squeeze(mean(v10_box, [1 2]));

% Calculate wind speed [m/s]
% Explication: 
% Le symbole .^2 permet de mettre au carré chaque valeur du vecteur individuellement.
wind_speed = sqrt(u10_box_mean.^2 + v10_box_mean.^2);

% Calculate meteorological wind direction [degrees] useful for the incoming
% concentration of PM 2.5
% Explication:
% Les composantes u10 et v10 indiquent vers où se déplace le vent. 
% Cependant, en météorologie, on indique la direction d'où vient le vent.
% C'est pour ça qu'on met un moins devant u10 et v10.
% atan2d() calcule l'angle à partir des deux composantes du vecteur, directement en degrés.
% Cette fonction retourne  un angle compris entre −180° et 180°.
% La fonction mod() permet de convertir cet angle pour qu'il soit compris entre 0° et 360°
wind_direction = mod(atan2d(-u10_box_mean, -v10_box_mean), 360);


% Mixing layer height H(t)

% Calculate the hourly spatial mean of the boundary layer height [m]
% Explication: 
% On calcul la moyenne entre les deux points ERA5 situés dans notre boîte.
% Hypothèse du modèle : nous considérons la hauteur moyenne des deux points 
% ERA5 comme représentative de toute notre boîte.
% J'ai nomé H = hauteur moyenne dans la box, qu'on pourra utilisé pour l'équation.
H = squeeze(mean(blh_box, [1 2]));


% Temperature T(t)

% Calculate the hourly spatial mean of temperature [K]
T = squeeze(mean(t2m_box, [1 2]));

% Convert temperature from Kelvin to Celsius [°C]
% Explication
% Avoir T en celsius peut être plus simple pour les graphiques.
T_celsius = T - 273.15;


% PM2.5 concentration C_i

% Calculate the hourly spatial mean of PM2.5 concentration [µg/m3]
% Explication
% Cette fois la moyenne ce fait sur les 15 points à l'interieur de notre boite.
% Hypothèse du modèle : nous considérons que la moyenne arithmétique des 15 points
% est représentative de la concentration dans l'ensemble de notre boîte.
C_i = squeeze(mean(pm2p5_box, [1 2]));


% Background concentration C_i0
% Explication: Nous avons déjà sélectionné les points extérieurs à notre boîte. 
% Il faut maintenant calculer leur moyenne spatiale pour chaque heure.
% Calculate hourly mean PM2.5 concentrations outside the box [µg/m3]
C_west = squeeze(mean(pm2p5_west, [1 2]));
C_east = squeeze(mean(pm2p5_east, [1 2]));
C_north = squeeze(mean(pm2p5_north, [1 2]));
C_south = squeeze(mean(pm2p5_south, [1 2]));

% Calculate incoming air flow weights [m^2/s]
w_west = max(u10_box_mean, 0) * height_box_sofia;
w_east = max(-u10_box_mean, 0) * height_box_sofia;

w_south = max(v10_box_mean, 0) * width_box_sofia;
w_north = max(-v10_box_mean, 0) * width_box_sofia;

% Calculate incoming PM2.5 concentration [µg/m3]
w_total = w_west + w_east + w_south + w_north;

C_i0 = (w_west .* C_west + w_east .* C_east ...
    + w_south .* C_south + w_north .* C_north) ...
    ./ w_total;

% Handle hours without wind
C_i0(w_total == 0) = C_i(w_total == 0);


% Effective box length delta_x

% Define the characteristic box length [m]
% Nous supposons une longueur caractéristique constante, indépendante de la direction du vent.
delta_x = (width_box_sofia + height_box_sofia) / 2;

% Dry deposition velocity vd
vd = 0.0018;


% Emission rate q(t)
% Import emission rate qi [kg/m²/h]

emission_data = load('data_01_2024/emission_rate_01_2024.mat');

qi = emission_data.q;