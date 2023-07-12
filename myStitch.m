function [Im, H] = myStitch(im1, im2)
    % % images in gray for corners and descriptors
    gray1 = rgb2gray(im1);
    gray2 = rgb2gray(im2);

    rhom = 5;
    rhoM = 20;
    rhostep = 1;
    N = 30;

    % % corner detection
    corners1 = myDetectHarrisFeatures(gray1);

    % descriptors
    descSize = (rhoM - rhom + 1) / rhostep;
    cornersNum = size(corners1, 1);
    descriptors1 = zeros(cornersNum, descSize);
    for i = 1 : cornersNum
        descriptors1(i, :) = myLocalDescriptor(gray1, ...
            corners1(i, :), rhom, rhoM, rhostep, N);
    end

    % % remove corner points with zero descriptors 
    % % i.e. too close to the edges of the image
    nonZeroIndices = any(descriptors1, 2);
    descriptors1 = descriptors1(nonZeroIndices, :);
    corners1 = corners1(nonZeroIndices, :);

    % % corner detection for image 2
    corners2 = myDetectHarrisFeatures(gray2);

    % % get descriptors of corners for image 2
    cornersNum = size(corners2, 1);
    descriptors2 = zeros(cornersNum, descSize);
    for i = 1 : cornersNum
        descriptors2(i, :) = myLocalDescriptor(gray2, ...
            corners2(i, :), rhom, rhoM, rhostep, N);
    end

    % % remove corner points with zero descriptors
    nonZeroIndices = any(descriptors2, 2);
    descriptors2 = descriptors2(nonZeroIndices, :);
    corners2 = corners2(nonZeroIndices, :);

    % % match descriptors between the two images
    matching = descriptorMatching(descriptors1, descriptors2, 0.1);

    matchingPoints = [corners1(matching(:, 1), :), ...
        corners2(matching(:, 2), :)];

    % % find transformation from matched points
    [H, ~, ~] = myRANSAC(matchingPoints, 10, 100 * length(matchingPoints));

    d = ceil(H.d);
    theta = rad2deg(H.theta);
    % perform stitching
    % rotate first image
    im1rot = imrotate(im1, theta);

    % calculate dimensions
    [M1, N1, ~] = size(im1rot);
    [M2, N2, ~] = size(im2);
    M = max(max(M1, M2), min(M1, M2) + abs(d(1)));
    N = max(max(N1, N2), min(N1, N2) + abs(d(2)));
    Im = zeros(M, N, 3);

    % place images
    if d(1) >= 0 && d(2) < 0
        Im(1:M1, 1:N1, :) = im1rot;
        Im(1 + d(1):M2 + d(1), 1 - d(2):N2 - d(2), :) = im2;
    elseif d(1) < 0 && d(2) < 0
        Im(1 - d(1):M1 - d(1), 1:N1, :) = im1rot;
        Im(1:M2, 1 - d(2):N2 - d(2), :) = im2;
    elseif d(1) >= 0 && d(2) >= 0
        Im(1:M1, 1 + d(2):N1 + d(2), :) = im1rot;
        Im(1 + d(1):M2 + d(1), 1:N2, :) = im2;
    elseif d(1) < 0 && d(2) >= 0
        Im(1 - d(1):M1 - d(1), 1 + d(2):N1 + d(2), :) = im1rot;
        Im(1:M2, 1:N2, :) = im2;
    end

end
