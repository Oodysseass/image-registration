function [H, inlierMatchingPoints, outlierMatchingPoints] = myRANSAC...
    (matchingPoints, r, N)
    % extract points
    points1 = matchingPoints(:, 1:2);
    points2 = matchingPoints(:, 3:4);

    % for N times, choose random pair of points
    % find transformation H
    % calculate score as number of inliers
    indices = randperm(length(points1));
    best = 0;
    for i = 1 : N
        % extract two random pairs of points
        index1 = indices(randi(length(indices)));
        index2 = indices(randi(length(indices)));
        while index1 == index2
            index2 = indices(randi(length(indices)));
        end
        P1 = [points1(index1, :).', points1(index2, :).'];
        P2 = [points2(index1, :).', points2(index2, :).'];
        
        % least squares
        A = [P1(1, 1), -P1(2, 1), 1, 0;
             P1(2, 1), P1(1, 1), 0, 1;
             P1(1, 2), -P1(2, 2), 1, 0;
             P1(2, 2), P1(1, 2), 0, 1];
        b = [P2(1, 1); P2(2, 1); P2(1, 2); P2(2, 2)];
        x = A \ b;
        
        % transformation parameters
        theta = atan2(x(2), x(1));
        d = [x(3); x(4)];

        % rotation matrix
        R = [cos(theta), -sin(theta); sin(theta), cos(theta)];

        % perform temp transformation
        temp1 = points1 * R.' + d.';

        % check score
        distances = sqrt(sum((temp1 - points2) .^ 2, 2));
        score = sum(distances < r);
        if score > best
            best = score;
            H.theta = theta;
            H.d = d;
        end
    end

    % find inliers and outliers
    if best ~= 0
        theta = H.theta;
        R = [cos(theta), -sin(theta); ...
            sin(theta), cos(theta)];
        d = H.d;
        transformed = (points1 * R.') + d.';
    
        distances = sqrt(sum((transformed - points2) .^ 2, 2));
        inlierMatchingPoints = find(distances < r);
        outlierMatchingPoints = find(distances >= r);
    else
        H.theta = 0;
        H.d = 0;
        inlierMatchingPoints = [];
        outlierMatchingPoints = [];
    end

end
