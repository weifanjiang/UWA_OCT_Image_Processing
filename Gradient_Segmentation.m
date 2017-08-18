%% <Gradient_Segmentation.m>
%
% Weifan Jiang
% This function finds and marks the lymphatic vessels within an OCT image
% with an algorithm based on gradient calculation.

%=========================================================================

function Gradient_Segmentation(img)
    %% Function Parameters:
    % img: the OCT image being processed.
    
    %% Local Variables:
    
    % These parameters are used for Before_Segmentation.m to pre-process
    % scans, each parameter's function is specified in
    % Before_Segmentation.m.
    Lower_Bound = 12;
    Lower_Value = 0;
    Higher_Bound = 45;
    Higher_Value = 45;
    
    % gradient_method: indicates which gradient-calculating method would be
    % used to calculate gradient.
    %
    % possible values: 'sobel', 'prewitt', 'roberts', 'central', 'intermediate'.
    gradient_method = 'intermediate';
    
    % thr: gradient magnitude lower than this value would be treated as
    % noise and eliminated.
    
    % for sobel and prewitt operator, thr should be set to approximately 50
    % for roberts, thr should be set to about 15
    % for central and intermediate, thr should be set to about 5
    thr = 5;
    
    % vessel_intensity: in the original picture, any pixel with intensity
    % lower than thr is determined to be vessel signal.
    % default = 10
    vessel_intensity = 25;
    
    % expect_vessel: expected vessel pixel number in the 5x5 window
    % centered in a target pixel.
    % default = 5
    expect_vessel = 5;
    
    % expect_grad: expected number of pixels with non-zero gradient within
    % an 5x5 window centered at the target pixel
    % default = 5
    expect_grad = 5;
    
    %% Display original image and process with pre-process function
    
    figure;
    
    subplot(2, 2, 1); imagesc(img, [Lower_Value Higher_Value]); title('Original Image'); colormap(gray);

    raw = Before_Segmentation(img, Lower_Bound, Lower_Value, Higher_Bound, Higher_Value);
    
    subplot(2, 2, 2); imagesc(raw); title('Before segmentation processing'); colormap(gray);
    
    %% Calculate Gradient of picture
    
    % Note: the default option of imgradient function in Matlab uses
    % Sobel's operator to calculate gradient magnitude and direction, other
    % operator can also be used, but other parameters may need to be
    % adjusted.
    
    [Gmag, Gdir] = imgradient(raw, gradient_method);
    
    % This algorithm would only analyze image based on Gradient magnitude
    % since lymphatic vessels usually don't process a regular shape.
    
    %% Use Thresholding to filter out low signal of gradient.
    
    % Since there are many noise pixels within the picture, and it differs
    % not much in intensity with surrounding pixels, therefore it would
    % result in a small value of gradient magnitude thus needs to be
    % discarded.
    
    % use thr to eliminate lower magnitude pixels.
    
    [width, height] = size(Gmag);
    for j = (1:width)
        for k = (1:height)
            if Gmag(j, k) < thr
                Gmag(j, k) = 0;
            end
        end
    end
    
    
    %% Compare Gradient picture with original picture
    
    detect = zeros(width + 4, height + 4);
    detect(3:2+width, 3:2+height) = Gmag;
    raw_extend = zeros(width + 4, height + 4);
    raw_extend(3:2+width, 3:2+height) = raw;
    
    % All pixels with non-zero gradient magnitude in this picture will be
    % determined whether it is noise by counting the number of surrounding
    % vessel pixels and surrounding pixels with non-zero gradient magnitude
    % in a 5x5 window.
    
    % vessel_intensity, expected_vessel and expected_grad are used here.
    
    for center_x = (3:2+width)
        for center_y = (3:2+height)
            if detect(center_x, center_y) > 0
                
                raw_count = 0; % count number of edge pixels within the window
                
                edge_count = 0; % count non-zero gradient magnitude pixels
                
                for delta_x = (-2:2)
                    for delta_y = (-2:2)
                        
                        if raw_extend(center_x - delta_x, center_y - delta_y) < vessel_intensity
                            raw_count = raw_count + 1;
                        end
                        
                        if detect(center_x - delta_x, center_y - delta_y) > 0
                            edge_count = edge_count + 1;
                        end
                    end
                end
                
                % Set a pixel's gradient magnitude to zero if either the
                % vessel pixel count or gradient magnitude pixel number
                % count fails to meet the expected standard.
                
                if raw_count < expect_vessel
                    detect(center_x, center_y) = 0;
                end
                if edge_count < expect_grad
                    detect(center_x, center_y) = 0;
                end
            end
        end
    end
    
    % Resize the picture to original size.
    detect = detect((3:2+width), (3:2+height));
    
    %% Apply a 3x3 mean filter to the graph to reduce small noises.
    denoise = detect;
    
    [width, height] = size(denoise);
    mean_filted = zeros(width + 2, height + 2);
    outer = zeros(width + 4, height + 4);
    outer(3:width + 2, 3:height + 2) = denoise;
    
    % Add up surrounding pixel's intensity.
    for j = [-1, 0, 1]
        for k = [-1, 0, 1]
            mean_filted = mean_filted + outer(2 + j:width + 3 + j, 2 + k:height + 3 + k);
        end
    end
    % Take average.
    mean_filted = mean_filted / 9;
    
    % Resize the window to original size.
    mean_filted = mean_filted(3:width + 2, 3:height + 2);
    
    denoise = mean_filted;
    
    %% Binarilize the image for better viewing.
    % by setting non-zero pixels to 255 intensity.
    
    for j = (1:width)
        for k = (1:height)
            if denoise(j, k) ~= 0
                denoise(j, k) = 255;
            else
                denoise(j, k) = 0;
            end
        end
    end
    
    
    %% display final picture.
    
    final = denoise;
    subplot(2, 2, 3); imagesc(final); title(gradient_method); colormap(gray);
end