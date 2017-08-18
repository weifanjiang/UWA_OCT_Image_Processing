%% <Surface_Detection_With_Snake.m>
%
% Weifan Jiang
% This function detects the surface of an OCT scan image with active
% contour algorithm (snakes).

%=========================================================================

function Surface_Detection_With_Snake(img)

    %% Function Parameters:
    % img: image which surface needs to be find.
    
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
    Iteration_Count = 1300;
    
    %% Display original image and process with pre-process function
    
    figure;
    
    subplot(2, 2, 1); imagesc(img, [Lower_Value Higher_Value]); title('Original Image'); colormap(gray);
    
    raw = Before_Segmentation(img, Lower_Bound, Lower_Value, Higher_Bound, Higher_Value);
    
    subplot(2, 2, 2); imagesc(raw); title('Before segmentation processing'); colormap(gray);
    
    %% Using active contour to find the upper & lower edges of image's exterior surface.

    [width, height] = size(raw);

    % initial mask of active contour, can be adjusted based on property of
    % original graph.
    mask = zeros(width, height);
    mask(10:end-10, 10:end-10) = 1;
    
    % Outputs the background of image.
    % Background should be set to black (index = 0) while image set to
    % white (index = 1).
    background = activecontour(raw, mask, Iteration_Count);
    
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
    
    subplot(2, 2, 3); imagesc(background); title('Background'); colormap(gray);
    
    %% Get the upper boundary of background and plot on picture
    
    final = img;
    for j=(1:height)
        
        ptr = 1;
        
        % Keep iterating until ptr represents a black pixel
        while ptr < width - 10 && background(ptr, j) == 0 && min(background(ptr + 1:ptr+5, j)) == 0
            ptr = ptr + 1;
        end
        
        final(ptr, j) = 255;
        
    end
    
    %% Display and return answer.
    
    subplot(2, 2, 4); imagesc(final); title('Upper surface marked.'); colormap(gray);
end