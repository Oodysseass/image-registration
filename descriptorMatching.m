function matchingPoints = descriptorMatching(points1, points2, ...
    percentageThreshold)
    % calculate distance matrix
    % it is explained in the report why this is a distance matrix
    D = sqrt(sum(points1 .^ 2, 2) - 2 * points1 * points2 .' ...
        + sum(points2 .^2, 2).');

    % find how many elements is the percentage threshold
    % either percentage threshold or 2000, whatever is less
    if percentageThreshold * numel(D) < 2000
        keepNum = ceil(percentageThreshold * numel(D));
    else
        keepNum = 2000;
    end

    % find elements
    flatD = D(:);
    [~, indices] = sort(flatD);
    indices = indices(1:keepNum);
    [indices1, indices2] = ind2sub(size(D), indices);
    
    matchingPoints = [indices1, indices2];
end