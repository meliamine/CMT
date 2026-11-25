% Projet CMT - PM2.5 Sofia
% Periode : janvier 2024

% Nettoie l'environnement de travail
clear;
clc;
close all;

% Define the geographic boundaries of our box in Sofia
lat_north = 42.85;  % [°]
lat_south = 42.60;  % [°]

lon_west = 23.10;   % [°]
lon_east = 23.60;   % [°]

% Define the dimentions of our box
% Tanks to a website, we found:
width_box_sofia = 40.76 * 10**3; % [m]
height_box_sofia = 27.8 * 10**3; % [km]

fprintf('Longueur Nord-Sud : %.2f km\n', height_box_sofia);
fprintf('Longueur Est-Ouest : %.2f km\n', width_box_sofia);

% Surface de la boite
A_box_sofia = width_box_sofia * height_box_sofia; % [km^2]

fprintf('Surface : %.2f km^2\n',A_box_sofia);

%% Import the data for January 2024
% Import wind data

project_folder = fileparts(mfilename('fullpath'));
file_vent = fullfile(project_folder, 'data_01_2024', 'vent_01_2024.nc');

% Import wind data
u10 = ncread(file_vent, 'u10');
v10 = ncread(file_vent, 'v10');
lat = ncread(file_vent, 'latitude');
lon = ncread(file_vent, 'longitude');
time = ncread(file_vent, 'valid_time');