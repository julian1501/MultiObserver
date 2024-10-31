function eta = etaSetup(u,noiseFactor,noisePower,setString,CMOdict)
    % This function defines the composite input/noise vector eta: [u; v;
    % eta;w]. Where u is input, vi is sensor noise, tau is the attack 
    % signal and w is process noise.

    tsize = size(u,2);
    [numObservers, numObserverOutputs] = selectObserverSpecs(setString,CMOdict);
    numOriginalStates = CMOdict('numOriginalStates');
    numOutputs = CMOdict('numOutputs');
    M = CMOdict('M');

    % Generate N (m x tsize) sensor noise signals
    v = noiseFactor*wgn(numObservers*numObserverOutputs,tsize,noisePower);

    % Generate N (n x tsize) attack signals
    % Select which outputs will be attacked, form 2 subsets of numOutputs
    % sized n. the first subset will be denoted by a value of 1 and the
    % second by a value of 2.
    
    tau = zeros(numObservers*numOriginalStates,tsize);

    % Generate an (n x tsize) process noise signal
    w = zeros(numOriginalStates,tsize);

    eta = [u;v;tau;w];
end