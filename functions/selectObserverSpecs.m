function [numObservers,numOutputsObserver] = selectObserverSpecs(setString,CMOstruct)
    % This function selects the number of observers in the set and the
    % number of outputs that each observer has from the setString, a string
    % indicating whether the observer is part of the P or J set.

    if setString == 'J'
        numObservers = CMOstruct.numJObservers;
        numOutputsObserver = CMOstruct.numOutputsJObservers;
    elseif setString == 'P'
        numObservers = CMOstruct.numPObservers;
        numOutputsObserver = CMOstruct.numOutputsPObservers;
    else
        error('setString is not equal to P or J.',setString);
    end

end