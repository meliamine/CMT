% CMT Project - PM2.5 emissions in Sofia
% Calculation of the hourly emission flux q(t)
% Period: January 2024

clear;
clc;
close all;

%% 1. Define the geographic boundaries of the box

lat_north = 42.85;
lat_south = 42.60;
lon_west = 23.10;
lon_east = 23.60;

% Box dimensions [m]
width_box_sofia = 40.76 * 1000;
height_box_sofia = 27.8 * 1000;

% Box surface [m²]
A_box = width_box_sofia * height_box_sofia;

%% 2. Import emission files

folder = 'data_emissions';

% fullfill construit le chemin vers le fichier, 
% dir cherche tous les fichiers correspondant au nom indiqué.
files = dir(fullfile(folder, 'PM2_5_*_2026_GRID_2024.txt'));


% Exclude the file containing total emissions
% On exclu le fichier NT qui contient les émissions totales
files = files(~contains({files.name}, 'PM2_5_NT_'));

% Display the selected files
disp({files.name}');

%% 3. Calculate annual emissions for each sector

columns = {'ISO2', 'YEAR', 'SECTOR', 'POLLUTANT', ...
           'LONGITUDE', 'LATITUDE', 'UNIT', 'EMISSION'};

% Initialize vectors
E_annual = zeros(length(files), 1);
n_cells = zeros(length(files), 1);
sectors = strings(length(files), 1);

for i = 1:length(files)

    % Import the file
    filename = fullfile(folder, files(i).name);

    data = readtable(filename, ...
        'Delimiter', ';', ...
        'ReadVariableNames', false, ...
        'CommentStyle', '#');

    data.Properties.VariableNames = columns;

    % Select cells inside the Sofia box
    sofia = data(strcmp(data.ISO2, 'BG') & ...
        data.LATITUDE >= lat_south & ...
        data.LATITUDE <= lat_north & ...
        data.LONGITUDE >= lon_west & ...
        data.LONGITUDE <= lon_east, :);

    % Store results for each sector
    E_annual(i) = sum(sofia.EMISSION);
    n_cells(i) = height(sofia);
    sectors(i) = string(data.SECTOR{1});

end

%% 4. Display results

results = table(sectors, n_cells, E_annual);
disp(results);

% Total annual emissions [Mg/year]
E_total = sum(E_annual);

fprintf('Total annual emissions: %.3f Mg/year\n', E_total);

%% 5. Apply EDGAR monthly temporal profiles

% January emission fractions
f_january = [
    0.08553;    % A - PublicPower
    1/12;       % B - Industry
    0.19069;    % C - OtherStationaryComb
    1/12;       % D - Fugitive
    0.08130;    % E - Solvents
    0.07978;    % F - RoadTransport
    1/12;       % G - Shipping
    0.08333;    % H - Aviation
    0.08002;    % I - Offroad
    0.08333;    % J - Waste
    0.08333;    % K - AgriLivestock
    0.08333;    % L - AgriOther
    1/12        % M - Other
];

% Calculate January emissions [Mg/month]
E_january = E_annual .* f_january;

% Total January emissions [Mg/month]
E_january_total = sum(E_january);

% Display results
results = table(sectors, E_annual, f_january, E_january);
disp(results);

fprintf('Total January emissions: %.3f Mg\n', ...
    E_january_total);

%% 6. Calculate the mean emission flux for January

% Convert emissions from Mg to kg
E_january_kg = E_january_total * 1000;

% Number of hours in January
hours_january = 31 * 24;

% Mean emission flux [kg/m²/h]
q_mean = E_january_kg / (A_box * hours_january);

fprintf('Mean emission flux: %.6e kg/m²/h\n', q_mean);

%% 7. Save the emission rate

% Assume constant hourly emissions within January
q = q_mean * ones(744, 1);

% Save the emission rate
save('data_01_2024/emission_rate_01_2024.mat', 'q');