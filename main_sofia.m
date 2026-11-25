% Projet CMT - PM2.5 Sofia
% Periode : janvier 2024

% Clean up the environnment of work
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
width_box_sofia = 40.76 * 10^3; % [m]
height_box_sofia = 27.8 * 10^3; % [km]

fprintf('Longueur Nord-Sud : %.2f km\n', height_box_sofia);
fprintf('Longueur Est-Ouest : %.2f km\n', width_box_sofia);

% Area of the box
A_box_sofia = width_box_sofia * height_box_sofia; % [m^2]

fprintf('Surface : %.2f m^2\n', A_box_sofia);

%% Import the data for January 2024

% ncdisp(file_height) --> Permet de visualiser la structure des data files

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
ncdisp(file_temperature);

% Define temperature's variables
t2m = ncread(file_temperature, 't2m');
lat_temperature = ncread(file_temperature, 'latitude');
lon_temperature = ncread(file_temperature, 'longitude');
time_temperature = ncread(file_temperature, 'valid_time');
