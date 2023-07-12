function d = myLocalDescriptorUpgrade(I, p, rhom, rhoM, rhostep, N)
    % % init descriptor
    circlesNum = floor((rhoM - rhom + 1) / rhostep);
    d = zeros(circlesNum, 1);

    % out of bounds
    if floor(p(2) + cos(0) * rhoM) > size(I, 2)             || ...
        floor(p(2) + cos(pi) * rhoM) <= 0                   || ...
        floor(p(1) + sin(pi / 2) * rhoM) > size(I, 1)       || ...
        floor(p(1) + sin(3 * pi / 2) * rhoM) <= 0
        return
    end

    % % scan
    angleStep = 2 * pi / N;
    % for each circle
    for r = rhom : rhostep : rhoM
        tempSum = 0;
        % for each point
        for i =  1 : angleStep : 2 * pi
            x = floor(p(1) + sin(i) * r);
            y = floor(p(2) + cos(i) * r);

            % sum value of point
            tempSum = tempSum + I(x, y);
        end
        d(r - rhom + 1, :) = tempSum / N;
    end
end
