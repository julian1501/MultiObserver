classdef noise
    % class to define noise at the start
    properties
        values
        times
    end

    methods
        function obj = noise(numOutputs,tspan,var)
            % define number of timesamples for noise
            steps = (tspan(2) - tspan(1))*20;
            stepsize = tspan(2)/steps;
            obj.times = tspan(1):stepsize:tspan(2);
            steps = size(obj.times,2);
            % setup noise vector
            obj.values = sqrt(var).*randn(numOutputs,steps);
        end

        function interpval = interpNoise(obj,outputs,t)
            % interpval returns the correct subset of outputs at the time t
            % the values will be interpolated from the correct timevalue if
            % t does not match with one that is in the obj.val
            %
            % if outputs is set to the string 'all' all outputs are used
            if strcmp(outputs,"all")
                outputs = 1:1:size(obj.values,1);
            end
            interpFullData = interp1(obj.times',obj.values',t)';
            interpval = interpFullData(outputs,1);
        end

        function MONoise = getMONoise(obj,t,type,Jmo,Pmo)
            % create the correct vector for a 2d cmo    
            
            % loop over J observers
            JmoNoise = zeros(Jmo.numOutputsObservers,1,Jmo.numObservers);
            for o = 1:1:Jmo.numObservers
                ids = Jmo.CiIndices(o,:);
                JmoNoise(:,:,o) = obj.interpNoise(ids',t);
            end

            PmoNoise = zeros(Pmo.numOutputsObservers,1,Pmo.numObservers);
            for o = 1:1:Pmo.numObservers
                ids = Pmo.CiIndices(o,:);
                PmoNoise(:,:,o) = obj.interpNoise(ids',t);
            end

            switch type
                case "2D"
                    MONoise = [reshape(JmoNoise,[],1,1); reshape(PmoNoise,[],1,1)];

                case "3D"
                    paddingSize1 = Jmo.numOutputsObservers-Pmo.numOutputsObservers;
                    padding = zeros(paddingSize1,1,Pmo.numObservers);
                    PmoNoisePadded = cat(1,PmoNoise,padding);
                    MONoise = cat(3,JmoNoise,PmoNoisePadded);

                otherwise
                    error("Supplied type is not compatible")
                
            end

        end

    end

end