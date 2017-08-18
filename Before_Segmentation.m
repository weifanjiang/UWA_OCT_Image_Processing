%% <Before_Segmentation.m>
%
% Weifan Jiang
% This function pre-processes an OCT image, including denoising,
% smoothing and contrast enhancement.

%=========================================================================

function final = Before_Segmentation(I, lower_bound, lower_value, higher_bound, higher_value)
    %% Function Parameters:
    % I: the OCT image being processed by this function
    % lower_bound: the lowest intensed pixel needed to be processed
    % lower_value: the lowest intensed pixel allowed in output
    % higher_bound: the highest intensed pixel needed to be processed
    % higher_value: the highest intensed pixel allowed in output
    
    %% Local Variables:
    
    % Step: indicates the height of each region where local intensity will
    % be calculated when adjusting attenuation.
    step = 15;
    
    % set_value: set_value is used to determine if a special pixel is noise
    % by looking at surrounding numbers of background pixels in 5x5 window.
    % If there are more than set_value amount of background pixels around a
    % special pixel, then that pixel is determined to be noise instead of
    % vessel.
    %
    % Larger set_value can filter out more noise but also produces the risk
    % of losing vessel pixels.
    set_value = 15;
    
    %% Median Filter to discard minor noises.
    
    img = medfilt2(I);
    
    %% Adjust attenuation of the picture
    
    [width, height] = size(img);
    
    ptr = 1;
    
    intensity = []; % holds all intensity levels for each region
    
    while ptr + step - 1 <= height
        
        curr = 0;
        
        % Add up all intensities in current region.
        for j = (1:width)
            for k = (ptr:ptr + step - 1)
                curr = curr + img(j, k);
            end
        end
        
        % Append  to intensity
        intensity = [intensity, curr];
        
        % Increment the pointer for current region.
        ptr = ptr + step;
    end
    
    % Re-scale each-region's intensity by setting each pixel's intensity
    % to:
    %
    % new_intensity = (old_intensity / average_intensity_of_region) *
    % max_regional_average_intensity
    
    count = 1;
    ptr = 1;
    while ptr + step - 1 <= height
        for j = (1:width)
            for k = (ptr:ptr + step - 1)
                img(j, k) = (img(j, k) / intensity(count)) * max(intensity);
            end
        end
        ptr = ptr + step;
        count = count + 1;
    end
    
    %% Set all pixels below lower_bound or above upper_bound to appropriate
    
    for j = (1:width)
        for k = (1:height)
            if img(j, k) < lower_bound
                img(j, k) = lower_value;
            end
            if img(j, k) > higher_bound
                    img(j, k) = higher_value;
            end
        end
    end
    
    %% Compare processed image with original image
    
    % set a pixel A in processed image to non-special if there are more than
    % a certain value of non-special pixels in the 5x5 window centered at A
    % in the original picture.
    
    % use set_value to determine if a pixel is noise.
    
    detect = zeros(width + 4, height + 4);
    detect(3:2+width, 3:2+height) = img;
    
    for center_x = (3:2+width)
        for center_y = (3:2+height)
            count = 0;
            %sum = 0;
            for delta_x = (-2:2)
                for delta_y = (-2:2)
                    %sum = sum + detect(center_x + delta_x, center_y + delta_y);
                    if detect(center_x + delta_x, center_y + delta_y) == lower_value
                        count = count + 1;
                    end
                end
            end
            if count > set_value
                detect(center_x, center_y) = 0;
                % detect(center_x. center_y) = sum / 25;
            end
        end
    end
    
    % Note: there is also the option to set the intensity to average of the
    % 25-pixel window instead of setting it directly to 0, which option is
    % better depends on other parameters and the gradient-calculating
    % method used previously.
    
    % Rescale the picture to original.
    detect = detect((3:2+width), (3:2+height));
    
    %% Return final answer
    
    final = detect;
end