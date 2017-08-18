%% <Snake.m>
%
% Weifan Jiang
% This function finds and marks the lymphatic vessels within an OCT image
% with the active contour model (Snake) algorithm.

%=========================================================================

function Snake(img)
    
    %% Function Parameters:
    % img: the OCT image needs to be processed.
    
    %% Local Variables:
    
    % These parameters are used for Before_Segmentation.m to pre-process
    % scans, each parameter's function is specified in
    % Before_Segmentation.m.
    Lower_Bound = 12;
    Lower_Value = 0;
    Higher_Bound = 45;
    Higher_Value = 45;
    
    % Iteration_Count: the maximum iterations active contour is run. This
    % number can be changed based on the complexity of exterior shape of
    % image, as well as the size of image (i.e. larger image requires more
    % iterations for the snake to reach inside).
    
    % This one is used for initial active contour which detects the surface
    Iteration_Count_1 = 1000;
    % This one is used for active contouring inside of image.
    Iteration_Count_2 = 1000;
    
    % pushing: push the averaged esum line downward to ensure it is within
    % the inner part of OCT image. This value should be adjusted based on
    % image.
    pushing = 114;
    
    % thick: how thick the mask should be initially, this value should also
    % be adjusted based on image.
    thick = 150;
    
    % expected_pixel: the maximum intensity a pixel holds in order to be
    % determined as vessel
    % default = 20
    expected_pixel = 30;
    
    % ecpected count: for each pixel determined as vessel in result of
    % active contour applied in last part, the surrounding 3x3 window in
    % raw picture is expected to contain at least this number of pixels
    % with expected_pixel intensity.
    % default = 3
    expected_count = 1;
    
    
    %% Display original image and process with pre-process function
    
    figure;
    subplot(2, 3, 1); imagesc(img, [Lower_Value Higher_Value]); title('Original Image'); colormap(gray);
    
    raw = Before_Segmentation(img, Lower_Bound, Lower_Value, Higher_Bound, Higher_Value);
    
    subplot(2, 3, 2); imagesc(raw); title('Before segmentation processing'); colormap(gray);
    
    %% Find centers of all the connected regions of pixels with intensity = 0
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    % ========================================================= %
    % ========================================================= %
    % ========== Please keep this part commented ============== %
    % ========================================================= %
    % ========================================================= %
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    
    % Note: this part implements an algorithm of Breath-First
    % Search based on graph theory of Computer Science.
    
    % It may work for small pictures, but the data size for this project is
    % too large for this part to work efficiently. Thus keeping this part
    % commented is essential for this function to run.

%     [width, height] = size(raw);
%     ptr = 1;
%     flags = zeros(width, height);
%     centers = [];
%     
%     while ptr <= width * height
%         ptr_x = mod(ptr, width);
%         ptr_y = floor(ptr / width) + 1;
%         
%         if flags(ptr_x, ptr_y) == 0 && raw(ptr_x, ptr_y) == 0
%             
%             curr = [ptr_x, ptr_y];
%             toExplore = [ptr_x, ptr_y];
%             seen = zeros(width, height);
%             seem(ptr_x, ptr_y) = 1;
%             
%             while sum(sum(toExplore)) ~= 0
%                 loc = toExplore(1, :);
%                 toExplore = toExplore(2:end, :);
%                 loc_x = loc(1);
%                 loc_y = loc(2);
%                 flags(loc_x, loc_y) = 1;
%                 curr = [curr
%                         loc_x, loc_y];
%                 
%                 
%                 if loc_x > 1
%                     if raw(loc_x - 1, loc_y) == 0 && flags(loc_x - 1, loc_y) == 0 && seen(loc_x - 1, loc_y) == 0
%                         toExplore = [toExplore
%                                      loc_x - 1, loc_y];
%                         seen(loc_x - 1, loc_y) = 1;
%                     end
%                 end
%                 if loc_y > 1
%                     if raw(loc_x, loc_y - 1) == 0 && flags(loc_x, loc_y - 1) == 0 && seen(loc_x, loc_y - 1) == 0
%                         toExplore = [toExplore
%                                      loc_x, loc_y - 1];
%                         seen(loc_x, loc_y - 1) = 1;
%                     end
%                 end
%                 if loc_x < width
%                     if raw(loc_x + 1, loc_y) == 0 && flags(loc_x + 1, loc_y) == 0 && seen(loc_x + 1, loc_y) == 0
%                         toExplore = [toExplore
%                                      loc_x + 1, loc_y];
%                         seen(loc_x + 1, loc_y) = 1;
%                     end
%                 end
%                 if loc_y < height
%                     if raw(loc_x, loc_y + 1) == 0 && flags(loc_x, loc_y + 1) == 0 && seen(loc_x, loc_y + 1) == 0
%                         toExplore = [toExplore
%                                      loc_x, loc_y + 1];
%                         seen(loc_x, loc_y + 1) = 1;
%                     end
%                 end
%             end
%             
%             all_x = curr(1, :);
%             all_y = curr(2, :);
%             
%             [num, gg] = size(all_x);
%             
%             centers = [centers
%                        floor(sum(all_x)/num), floor(sum(all_y)/num)];
%         end
%         ptr = ptr + 1;
%     end
%     
%     [centerCount, gg] = size(centers);
%     centerGraph = zeros(width, height);
%     for j = (1:centerCount)
%         centerGraph(centers(1, j), centers(2, j)) = 255;
%     end
%     figure; imagesc(centerGraph); title('Centers for black pixels regions'); colormap(gray);
    
    %% Using active contour to find the upper & lower edges of image's exterior surface.

    [width, height] = size(raw);

    % initial mask of active contour, can be adjusted based on property of
    % original graph.
    mask = zeros(width, height);
    mask(10:end-10, 10:end-10) = 1;
    
    % Outputs the background of image.
    % Background should be set to black (index = 0) while image set to
    % white (index = 1).
    background = activecontour(raw, mask, Iteration_Count_1);
    
    %% Denoise the background by removing selected pixels.
    
    % for each non-zero intensed pixel in the background image, set it to
    % non-special (i.e. change its intensity to 0) if there are no other
    % non-background pixels within the surrounding 3x3 window.
    backGround_extend = zeros(width + 2, height + 2);
    backGround_extend(2:end-1, 2:end-1) = background;
    
    for j = (2:width + 1)
        for k = (2:height + 1)
            if backGround_extend(j, k) > 0
                
                % Count surrounding non-zero pixels.
                count = 0;
                for delta_x = [-1 0 1]
                    for delta_y = [-1 0 1]
                        if backGround_extend(j + delta_x, k + delta_y) > 0
                            count = count + 1;
                        end
                    end
                end
                
                if count == 1
                    % count == 1 indicates only 1 non-background pixel
                    % inside 3x3 window (which is target pixel itself).
                    background(j - 1, k - 1) = 0;
                end
                
            end
        end
    end
    
    %% Binarilize original image to discard noise
    
    % Note: This part can be activated if there are too many noises that
    % the previous denoise portions cannot handle. Since the
    % Before_Segmentation.m function oftern set the center of each vessel
    % to 0 intensity, binarilize the "raw" picture can discard many noises,
    % but also produces great risk of discarding useful informations.
    
    % Not recommended in most of the situations.
    
%     for j = (1:width)
%         for k = (1:height)
%             if raw(j, k) ~= 0
%                 raw(j, k) = 1;
%             end
%         end
%     end
    
    %% Apply mean filter to background to further remove small noises.
    
    denoise = background;
    mean_filted = zeros(width + 2, height + 2); % Applied in 3x3 window.
    outer = zeros(width + 4, height + 4);
    outer(3:width + 2, 3:height + 2) = denoise;
    for j = [-1, 0, 1]
        for k = [-1, 0, 1]
            mean_filted = mean_filted + outer(2 + j:width + 3 + j, 2 + k:height + 3 + k);
        end
    end
    mean_filted = mean_filted / 9;
    
    %Resize to original size.
    mean_filted = mean_filted(3:width + 2, 3:height + 2);
    background = mean_filted;
    
    % Binarilize background.
    for j = (1:width)
        for k = (1:height)
            if background(j, k) ~= 1
                background(j, k) = 0;
            end
        end
    end
    
    subplot(2, 3, 3);  imagesc(background); title('Background'); colormap(gray);
    
    %% Remove background in the previous image by setting background to a smooth color
    
    for j = (1:width)
         for k = (1:height)
             if background(j, k) == 0
                 
                 % background(j, k) == 0 indicates that it is not the
                 % useful portion of picture, thus we set the corresponding
                 % pixel in raw picture to a smooth color, which will be
                 % less-likely influncing the snake as it changes iteration
                 % by iteration.
                 
                 % Since the original picture is between 0-45, we choose a
                 % value in between for the background, seems like 27 works
                 % the best by experience.
                 raw(j, k) = 27;
             end
         end
    end
    
    subplot(2, 3, 4); imagesc(raw); title('Background removed in original picture'); colormap(gray);
    
    %% Construct a mask to explore the interior of image.
    
    mask2 = zeros(width, height); % make sure the mask has same size as original picture.
    
    % We choose the initial place of mask to be the averge of position of 
    % the first black pixel in each column. 
    
    esum = 0; %% keep track of sum of all first black pixels' positions
    
    for j=(1:height)
        
        ptr = 1;
        
        % Keep iterating until ptr represents a black pixel
        while ptr < width && background(ptr, j) == 0
            ptr = ptr + 1;
        end
        esum = esum + ptr;
        
    end
    
    esum = floor(esum / height); % Divide by total number of columns.
    
    % Adjust the initial position of snake with pushing and determine the
    % range of window by thick.
    
    esum = esum + pushing;
    
    % Set the region in mask2 to be 1.
    mask2(esum:esum + thick, :) = 1;
    
    subplot(2, 3, 5); imagesc(mask2); title('Second mask'); colormap(gray);
    
    
    %% Apply actvie contour to raw picture
    
    % At this point, the black background of raw should be changed to a
    % smooth color, so the snake will go inside the image.
    
    fig = activecontour(raw, mask2, Iteration_Count_2);
    
    %% Construct final result with previous answers
    
    % Count surrounding 3x3 window in the raw picture of any pixel defined
    % as vessel from active coutour, discard pixels do not meet standard.
    
    % Use ecxpected_pixel and expected_count to filter out unwanted noises.
    
    result = ones(width, height);
    for j = (2:width-1)
         for k = (2:height-1)
             
             % 0 intensity: vessel pixel
             if fig(j, k) == 0
                 count = 0;
                 for delta_x = [-1 0 1]
                     for delta_y = [-1 0 1]
                         if raw(j + delta_x, k + delta_y) < expected_pixel
                             count = count + 1;
                         end
                     end
                 end
                 if count > expected_count
                     % Set to 0 indicates a vessel-pixel is marked black in
                     % result.
                     result(j, k) = 0;
                 end
             end
         end
    end
    
    %% Return final answer.
    
    final = result;
    subplot(2, 3, 6); imagesc(final); title('final result'); colormap(gray);
end