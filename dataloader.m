% Load SDSS spectra from folder and match labels from CSV

fitsFiles = dir('sdss_spectra\*.fits');
tbl = readtable('FITS_labels.csv');    % CSV with filename + label columns

% Target wavelength grid
lambdaTarget = linspace(3800,9200,3828);

X = zeros(length(fitsFiles),3828);
Y = categorical(strings(length(fitsFiles),1));
Errs1 = strings(length(fitsFiles),1);

for f = 1:length(fitsFiles)
    file = fitsFiles(f).name;

    % Look up index for this file in csv
    idx = find(strcmp(tbl.filename, file));
    if ~any(idx)
        Errs1(f)=file;
        fprintf('Skipping %s (no label found)\n', file);
        continue;
    end

    % Read binary table from FITS
    bt = fitsread(fullfile('sdss_spectra', file), 'BinaryTable', 1);

    % Convert log10 wavelength to Angstroms
    % Resample to common wavelength grid
    fluxResamp = interp1(10.^bt{2}, bt{8}, lambdaTarget, 'linear', 'extrap');

    % Normalize
    fluxResamp = fluxResamp / max(abs(fluxResamp));

    % Store
    X(f,:) = fluxResamp;
    Y(f) = categorical(tbl.D_Class(idx));
    fprintf('%d\n',f);
end

% Build datastore
dsX = arrayDatastore(X);
dsY = arrayDatastore(Y);
spectraDS = combine(dsX, dsY);

%% split into training and testing

cats = categories(Y);
numCats = numel(cats);

trainIdx = [];
testIdx = [];

for i = 1:numCats
    
    % find indices of samples in this category
    idxt = find(Y == cats{i});
   
    % randomly permute them
    idxt = idxt(randperm(numel(idxt)));
    
    % compute split point
    nTrain = round(0.8 * numel(idxt));
    
    % accumulate results
    trainIdx = [trainIdx; idxt(1:nTrain)];
    testIdx  = [testIdx;  idxt(nTrain+1:end)];
end

trainDS = subset(spectraDS, trainIdx);
testDS  = subset(spectraDS, testIdx);