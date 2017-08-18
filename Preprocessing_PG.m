
%% <Preprocessing_PG.m>
%
%
% Peijun Gong, 2017.07.24
% This function preprocesses OCT the scans.
%==========================================================================

%% Check OCT B-scans.

% Get the number of B-scans.
y_size = size(log_OCT, 2);

% Display several B-scans to select a volume to calculate the noise floor.
bscan = (squeeze(log_OCT(:,2,:)))';
%figure; imagesc(bscan); colormap(gray); colorbar;
bscan = (squeeze(log_OCT(:,round(y_size/2),:)))';
%figure; imagesc(bscan); colormap(gray); colorbar;
bscan = (squeeze(log_OCT(:,y_size,:)))';
%figure; imagesc(bscan); colormap(gray); colorbar;


%% Process the noise floor.

% Select the volume for calculating the noise floor.
noise_xpix = [900, 1000];
noise_ypix = [1, 10];
noise_zpix = [900, 1000];

% Calculate and process  the noise floor.
noise_volume = log_OCT(noise_xpix(1):noise_xpix(2), noise_ypix(1):noise_ypix(2), noise_zpix(1):noise_zpix(2));
noise_floor = mean(noise_volume(:));
log_OCT = log_OCT - noise_floor;


%% Check the B-scan after processing the noise floor.

% Specify the location of the B-scan.
y_idx = 145;

% B-scan after processing the noise floor.
bscan_af = (squeeze(log_OCT(:, y_idx, :)))';
%figure; imagesc(bscan_af, [0 45]); colormap(gray); colorbar;

%% Calling the image segmentation function

Surface_Detection_With_Snake(bscan_af);

%% End of the function.