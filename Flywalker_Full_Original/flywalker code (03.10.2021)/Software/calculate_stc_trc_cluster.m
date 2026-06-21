%contains a cell with n rows and 1 column, with n=number os legs
%each row contains a cell with 1 row and m columns, with m=number os steps
%each column contains a matrix 1x2 with the x and y coordinates for each
%step respectively

%legs are numbered from 1 to 6 
%LF-1
%LM-2
%LH-3
%RF-4
%RM-5
%RH-6

function stc_trc_cluster = calculate_stc_trc_cluster(steps, show_graph)

    if ~exist('show_graph', 'var')
        show_graph = 0;
    end
    
    if show_graph == 1
        % Plot the steps
        for leg = 1:length(steps)
            points = steps{1, leg};
            plot(points(:, 1), points(:, 2))
            hold on 
        end
    end

    % Calculate ROI
    [min_start_y_LF, min_stop_y_LF] = y_ROI(steps);    
    if show_graph == 1
        yline(min_start_y_LF, 'r')
        yline(min_stop_y_LF, 'b')
        hold off
    end

    tic
    int=20;%numero de intervalos de divisão das passadas
    x_to_consider_LF=xPointsOfInterest(steps, min_stop_y_LF, min_start_y_LF, int);%returns the x corresponding to each y of interest for all steps of each leg
    toc

    stc_trc_cluster=ParCalculator(x_to_consider_LF);
end

function point = selectFirstPoint(points)
% This function is used to resolve the conflits when there are multiple points for a single Y. 
% Imagine that we have a function such as y=x^2. In this case, y=4 can have to images x=2 or x=-2.
% In this scenario we must have a condition to choose what value we want,
% only the positives? Only the negatives? 
% This function can implement that type of logic.

    % A simple way of resolve a conflict by selecting the first row from
    % the list.
    point = points(1, :);
end

function stc_trace_cluster=ParCalculator(x_to_consider)
%Calculating the std for each row (each y)
    [row,col]=size(x_to_consider);
    std_row=[];
    for i=1:row
        values = x_to_consider(i,:);
        % Exclude the NaNs
        values = values(~isnan(values));
        std_row(i,1)=std(values);
    end

    stc_trace_cluster=sum(std_row)/row;%parameter value
end

function num_crosses = countIntersections(steps, y)

    counter = 0;
    numberSteps = length(steps);
    for i = 1:numberSteps
        step=steps{i};
        prevision = getPointsAtY(step, y, @selectFirstPoint);
        if ~isempty(prevision)
            counter = counter + 1;
        end
    end
    
    num_crosses = counter;
end

% %Defining the ROI where all traces have data points
function [min_start_y,min_stop_y]=y_ROI(leg_cell, min_steps)
    
    % Set the default number of legs to be used, 
    % when the user does not define it.
    if ~exist('min_steps', 'var')
        min_steps = 3;
    end

    [row,col]=size(leg_cell);
    start_y=[];
    stop_y=[];

    for i=1:col
        start_y=[start_y leg_cell{1,i}(1,2)];%vector that saves all first points of each step
        stop_y=[stop_y leg_cell{1,i}(end,2)];%vector that saves all last points of each step
    end
    
    minimum_list_y = sort(real(start_y), 'descend');
    maximum_list_y = sort(real(stop_y), 'ascend');
    
    min_start_y=minimum_list_y(1);%finds the smallest point of all starting points legs
    min_stop_y=maximum_list_y(1);%finds the biggest point of the stopping points
    
    % Shrink the start
    current_index_start = 1;
    while countIntersections(leg_cell, min_start_y) < min_steps
        min_start_y = minimum_list_y(current_index_start);
        current_index_start = current_index_start + 1;
    end
    % Shrink the stop
    current_index_stop = 1;
    while countIntersections(leg_cell, min_stop_y) < min_steps
        min_stop_y = maximum_list_y(current_index_stop);
        current_index_stop = current_index_stop + 1;
    end
    
    i = 1;
    while min_start_y < min_stop_y
        if length(start_y(start_y < min_stop_y)) == 1
            i = i + 1;
            min_start_y = minimum_list_y(i);
        else
            i = i + 1;
            min_stop_y = maximum_list_y(i);
        end
    end
    assert(min_start_y > min_stop_y, 'Valor impossivel')

end

function x_to_consider=xPointsOfInterest(steps,min_stop_y,min_start_y,int)
%%Calculating the x's corresponding to the y's of interest
    range=(min_stop_y-min_start_y)/int;
    points_to_consider=min_start_y:range:min_stop_y;%confirmar que será subtracao em tds as patas
    
    x_to_consider=nan(int + 1, length(steps));
    for i=1:length(steps)
        for j=1:length(points_to_consider)
            list_of_steps = real(steps{1,i});
            y_to_find = points_to_consider(j);
            
            prevision = getPointsAtY(list_of_steps, y_to_find, @selectFirstPoint);
            if ~isempty(prevision)
                x_to_consider(j,i)=prevision(1);%matrix containing the x coordinate for each step(column) and each point to consider (row)
            end
        end
    end
end

function m = calculateSlope(lineStart, lineEnd)
% calculateSlope  Calculate the slope between two points.
%   m = calculateSlope(P1, P2) Both P are composed of an x and a y.
%   
%   Example:
%   m = calculateSlope([0, 0], [1, 1]);

    % [Safety] Safety checks for the type of arguments
    assert(ismatrix(lineStart) && size(lineStart, 1) == 1 && size(lineStart, 2) == 2, ...
        "The line start point, should be a matrix with 1 row by 2 columns");
    assert(ismatrix(lineEnd) && size(lineEnd, 1) == 1 && size(lineEnd, 2) == 2, ...
        "The line end point, should be a matrix with 1 row by 2 columns");

    m = (vpa(lineEnd(1, 2)) - lineStart(1, 2)) / (lineEnd(1, 1) - lineStart(1, 1));
end

function b = calculateIntersection(m, knownPoint)
% calculateIntersection  Calculate the b value for the equation y=m*x+b. 
%   m = calculateIntersection(m, P) m is calculated using the 
%   function calculateSlope(lineStart, lineEnd) and P is the list of
%   known points.
%   
%   Example:
%   b = calculateIntersection(1, [0 0 ; 1 1]);
    
    % [Safety] Safety checks for the type of arguments
    assert(isscalar(m), "m should be a scalar value")
    assert(ismatrix(knownPoint) && size(knownPoint, 1) == 1 && size(knownPoint, 2) == 2, ...
        "The known point, should be a matrix with 1 row by 2 columns");
    
    b = knownPoint(1, 2) - m * knownPoint(1, 1);
end

function prevision = calculateYFromLine(x, lineStart, lineEnd)
    % [Safety] Safety checks for the type of arguments
    assert(isscalar(y), "y should be a scalar value")
    assert(ismatrix(lineStart) && size(lineStart, 1) == 1 && size(lineStart, 2) == 2, ...
        "The line start point, should be a matrix with 1 row by 2 columns");
    assert(ismatrix(lineEnd) && size(lineEnd, 1) == 1 && size(lineEnd, 2) == 2, ...
        "The line start point, should be a matrix with 1 row by 2 columns");

    % Now we know the start and end position of the line.
    % Using the formula y = m * x + b we can predict the values.
    % Let«s start by calculating the m: m = (y2 - y1) / (x2 - x1)
    % Note: VPA method is used to keep a high precision on the operation
    m = calculateSlope(lineStart, lineEnd);
    % Now lets calculate b using the formula: b = y - m * x
    b = calculateIntersection(m, lineStart);
    % Now we have a full equation, we can predict the value for the expected
    % position.
    y_predict = m * x + b;
    prevision = [x y_predict];
end

function prevision = calculateXFromLine(y, lineStart, lineEnd)

    % [Safety] Safety checks for the type of arguments
    assert(isscalar(y), "y should be a scalar value")
    assert(ismatrix(lineStart) && size(lineStart, 1) == 1 && size(lineStart, 2) == 2, ...
        "The line start point, should be a matrix with 1 row by 2 columns");
    assert(ismatrix(lineEnd) && size(lineEnd, 1) == 1 && size(lineEnd, 2) == 2, ...
        "The line start point, should be a matrix with 1 row by 2 columns");

    % Now we know the start and end position of the line.
    % Using the formula y = m * x + b we can predict the values.
    % Let«s start by calculating the m: m = (y2 - y1) / (x2 - x1)
    % Note: VPA method is used to keep a high precision on the operation
    m = calculateSlope(lineStart, lineEnd);
    % Now lets calculate b using the formula: b = y - m * x
    b = calculateIntersection(m, lineStart);
    % Now we have a full equation, we can predict the value for the expected
    % position.
    if double(m) == 0
        x_predict = (lineStart(1, 1) + lineEnd(1, 1)) / 2;
    else
        x_predict = (y - b) / m;
    end
    prevision = [x_predict y];
end

function pointsFound = findLinesCrossingY(points, y)
% findLinesCrossingY  Find all lines that cross a given Y.
%   m = findLinesCrossingY(Poiunts, y)
%   
%   Example:
%   Points = [1 1 1 2 ; 1 2 2 2 ];
%   intersection = findLinesCrossingY(Points, 1.5);

    % [Safety] Safety checks for the type of arguments
    assert(ismatrix(points) && size(points, 2) == 2, ...
        "The list of points should be a matrix with N rows by 2 columns");
    assert(isscalar(y), "y should be a scalar value")

    pointsFound = [];
    for i = 2:size(points, 1)
        startPoint = points(i - 1, :);
        endPoint = points(i, :);
        
        % Look ahead the starting point
        if startPoint(1, 2) >= y && endPoint(1, 2) <= y
            pointsFound = [pointsFound ; startPoint endPoint];
        end
        % Look behind the starting point
        if startPoint(1, 2) <= y && endPoint(1, 2) >= y
            pointsFound = [pointsFound ; startPoint endPoint];
        end
    end
end

function prevision = getPointsAtY(points, y, onMultiplePointsFunction)
% getPointsAtY  Try to predict the intersection point
%   between a polyline and Y line.
%
% The function onMultiplePointsFunction should take the list of points that
% have been found and resolve the conflict by returning a single point that
% represents the intersection with the point.
%
%   intersectionPoint = getPointsAtY(Poiunts, y)
%   
%   Example:
%   Points = [1 1 1 2 ; 1 2 2 2 ];
%   intersection = getPointsAtY(Points, 1.5);
    
    % [Safety] Safety checks for the type of the values
    assert(ismatrix(points) && size(points, 2) == 2, ...
        "The list of points should be a matrix with N rows by 2 columns");
    assert(isscalar(y), "y should be a scalar value")
    
    % [Safety] Lets find out the minimun and maximum values for Y 
    minYVal = min(points(:, 2));
    maxYVal = max(points(:, 2));
    
    % [Safety] Check if the Y is between the minimum and the maximum
    if y < minYVal
       prevision = [];
       return
    end
    if y > maxYVal
       prevision = [];
       return
    end

    % Find the list of points that cross the y
    pointsCrossingY = findLinesCrossingY(points, y);
    
    if size(pointsCrossingY, 1) > 1
        
        % If there's no multiple points function set, an error occurres
        if ~exist('onMultiplePointsFunction', 'var')
            error("Found multiple points for y=%s. Try pass a function in param onMultiplePointsFunction to resolve the conflict.", num2str(y))
        end
        
        % If there's more then one point, we should pass the list of points
        % that have been found to the function "onMultiplePointsFunction"
        % that has been received in the arguments to resolve the conflict.
        pointsCrossingY = onMultiplePointsFunction(pointsCrossingY);
        assert(size(pointsCrossingY, 1) == 1 && size(pointsCrossingY, 2) == 4, ...
            "After the execution of the function, the result should be a matrix with 1 row and 4 columns but %s row and %s columns was given.", size(pointsCrossingY, 1), size(pointsCrossingY, 2))
    end
    
    % Calculate the intersection point
    lineStart = pointsCrossingY(1, 1:2);
    lineEnd = pointsCrossingY(1, 3:4);
    prevision = calculateXFromLine(y, lineStart, lineEnd);
end