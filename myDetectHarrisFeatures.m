function corners = myDetectHarrisFeatures(I)
    % image size and k parameter of algorithm
    [M, N] = size(I);
    k = 0.04;

    % sobel filters for gradients
    dx = [1 0 -1; 2 0 -2; 1 0 -1];
    dy = [1 2 1; 0 0 0;-1 -2 -1];

    % calculate gradients with convolution 
    Ix = imfilter(I, dx, "conv");
    Iy = imfilter(I, dy, "conv");

    % calculate components of matrix M, from harris paper
    % M = | A   C |
    %     | C   B |
    A = Ix .^ 2;
    B = Iy .^ 2;
    C = Ix .* Iy;

    % gaussian filter
    sigma = 1;
    A = imgaussfilt(A, sigma, 'FilterSize', 5);
    B = imgaussfilt(B, sigma, 'FilterSize', 5);
    C = imgaussfilt(C, sigma, 'FilterSize', 5);

    % array with harris value for each point
    R = zeros(M, N);
    for i = 1 : M
        for j = 1 : N
            % matrix M for point (i, j)
            Mat = [A(i, j) C(i, j); C(i, j) B(i, j)];
            R(i, j) = det(Mat) - k * trace(Mat) ^ 2;
        end
    end

    % dilate to enchance corner points
    R = imdilate(R, strel('square', 3));

    % hold only local maxima
    % so we don't keep multiple times the same corner
    binR = imregionalmax(R, 8);

    % enforce threshold
    Rthres = 0.01 * max(R(:));
    binR(R < Rthres) = 0;
    
    % although we used local maxima we still have duplicate entries
    binR = bwmorph(binR, 'shrink', Inf);

    % extract indices
    [rows, cols] = find(binR);
    corners = [cols, rows];

end