function [numObservers,numOutputsObserver] = selectObserverSpecs(setString,CMOdict)
    % This function selects the number of observers in the set and the
    % number of outputs that each observer has from the setString, a string
    % indicating whether the observer is part of the P or J set.

    if setString == 'J'
        numObservers = CMOdict('numJObservers');
        numOutputsObserver = CMOdict('sizeJObservers');
    elseif setString == 'P'
        numObservers = CMOdict('numPObservers');
        numOutputsObserver = CMOdict('sizePObservers');
    else
        error('setString is not equal to P or J.',setString);
    end

end