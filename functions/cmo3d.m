classdef cmo3d
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Property1
    end

    methods
        function obj = cmo3d(mo,inputArg2)
            %UNTITLED9 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = mo + inputArg2;
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end