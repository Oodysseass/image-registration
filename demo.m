close all
clear
warning("off", "all")

% % % ACTUAL DEMO FOR THE WHOLE PURPOSE OF THE CODE AKA PART 2
img1 = im2double(imread('imForest1.png'));
img2 = im2double(imread('imForest2.png'));

stitched = myStitch(img1, img2);
figure, imshow(stitched)

img1 = im2double(imread('im1.png'));
img2 = im2double(imread('im2.png'));

stitched = myStitch(img1, img2);
figure, imshow(stitched)


% % % FOR PART 1.1
% % find descriptor for point
p = [100, 100];
rhom = 5;
rhoM = 20;
rhostep = 1;
N = 8;
grayScale1 = rgb2gray(img1);
p1 = myLocalDescriptor(grayScale1, p, rhom, rhoM, rhostep, N);
p = [108, 198];
p2 = myLocalDescriptor(imrotate(grayScale1, -5), p, rhom, rhoM, rhostep, N);

q = [200, 200];
q1 = myLocalDescriptor(grayScale1, q, rhom, rhoM, rhostep, N);
q = [202, 202];
q2 = myLocalDescriptor(grayScale1, q, rhom, rhoM, rhostep, N);

% % not working well
% xy = [-1, -1, -1; -1, 8, -1; -1, -1, -1];
% lapl = imfilter(grayScale1, xy);
% lapl2 = imfilter(imrotate(grayScale1, -5), xy);
% p = [1072, 689];
% p1 = myLocalDescriptorUpgrade(lapl, p, rhom, rhoM, rhostep, N);
% p = [1128, 708];
% p2 = myLocalDescriptorUpgrade(lapl2, p, rhom, rhoM, rhostep, N);
% q = [200, 200];
% q1 = myLocalDescriptorUpgrade(lapl, q, rhom, rhoM, rhostep, N);
% q = [202, 202];
% q2 = myLocalDescriptorUpgrade(lapl, q, rhom, rhoM, rhostep, N);


% % HARRIS CORNER DETECTOR PART 1.2
% corner detection
corners1 = myDetectHarrisFeatures(grayScale1);
cornersMatlab = detectHarrisFeatures(grayScale1);
% figures
figure
imshow(img1)
hold on
scatter(corners1(:, 1), corners1(:, 2), ...
'Marker', '+', 'MarkerEdgeColor', 'red');
figure
imshow(img1)
hold on
scatter(cornersMatlab.Location(:, 1), ...
cornersMatlab.Location(:, 2), 'Marker', '+', 'MarkerEdgeColor', 'red');

grayScale2 = rgb2gray(img2);
corners2 = myDetectHarrisFeatures(grayScale2);
figure
imshow(img2)
hold on
scatter(corners2(:, 1), corners2(:, 2), ...
'Marker', '+', 'MarkerEdgeColor', 'red');


% % % DESCRIPTOR MATCHING AND RANSAC
% % % PART 1.3
% descriptors
N = 30;
descSize = (rhoM - rhom + 1) / rhostep;
cornersNum = size(corners1, 1);
descriptors1 = zeros(cornersNum, descSize);
for i = 1 : cornersNum
    descriptors1(i, :) = myLocalDescriptor(grayScale1, ...
            corners1(i, :), rhom, rhoM, rhostep, N);
end

% % remove corner points with zero descriptors 
% % i.e. too close to the edges of the image
nonZeroIndices = any(descriptors1, 2);
descriptors1 = descriptors1(nonZeroIndices, :);
corners1 = corners1(nonZeroIndices, :);

% % get descriptors of corners for image 2
cornersNum = size(corners2, 1);
descriptors2 = zeros(cornersNum, descSize);
for i = 1 : cornersNum
    descriptors2(i, :) = myLocalDescriptor(grayScale2, corners2(i, :), ...
                rhom, rhoM, rhostep, N);
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
[H, inliers, outliers] = myRANSAC(matchingPoints, 10, ...
    100 * length(matchingPoints));


% make a merged image to display results
[height1, width1, ~] = size(img1);
[height2, width2, ~] = size(img2);
maxHeight = max(height1, height2);
mergedWidth = width1 + width2;
mergedImage = zeros(maxHeight, mergedWidth, 3, 'like', img1);
mergedImage(1:height1, 1:width1, :) = img1;
mergedImage(1:height2, width1+1:end, :) = img2;

figure, imshow(mergedImage)
hold on
for i = 1 : length(outliers)
    index = outliers(i);
    corner1 = matchingPoints(index, 1:2);
    corner2 = matchingPoints(index, 3:4);
    plot(corner1(2), corner1(1), 's', ...
        'MarkerFaceColor', 'none', ...
        'MarkerEdgeColor', [.5 .5 .5], 'MarkerSize', 10);
    plot(corner2(2) + width1, corner2(1), 's', ...
        'MarkerFaceColor', 'none', ...
        'MarkerEdgeColor', [.5 .5 .5], 'MarkerSize', 10);
end
hold off

figure, imshow(mergedImage)
hold on
for i = 1 : length(inliers)
    index = inliers(i);
    corner1 = matchingPoints(index, 1:2);
    corner2 = matchingPoints(index, 3:4);
    ran = [rand rand rand];
    plot(corner1(2), corner1(1), 'o', ...
        'MarkerFaceColor', 'none', 'MarkerEdgeColor', ...
        ran, 'MarkerSize', 10);
    plot(corner2(2) + width1, corner2(1), 'o', ...
        'MarkerFaceColor', 'none', 'MarkerEdgeColor', ...
        ran, 'MarkerSize', 10);
    plot([corner1(2) corner2(2) + width1], [corner1(1) corner2(1)], ...
        'color', ran);
end

