function combs = combinations(sensors,varargin)
    % Generate all combinations of a variable number of arrays. This
    % function is built in from matlab 2023b onwards but it is not in 2022b
    % so this is a 'custom' implementation. Quick and dirty, copied/inspired
    % from/by a forum post.
    
    switch varargin{1}
        case 'loose'

            cellSensors = mat2cell(sensors, ones(1, size(sensors, 1)), size(sensors, 2));
            
            % Create grids for all input arrays using ndgrid
            grids = cell(1, numel(cellSensors));
            [grids{:}] = ndgrid(cellSensors{:});
            
            % Convert grids to a 2D matrix where each row is a combination
            numCombinations = numel(grids{1});
            combs = zeros(numCombinations, numel(cellSensors));
            
            for i = 1:numel(cellSensors)
                combs(:, i) = grids{i}(:);
            end

        case 'strict'

            combs = sensors';

    end

end