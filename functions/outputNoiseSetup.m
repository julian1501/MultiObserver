function outputNoise = outputNoiseSetup(maxNoise,CMOstruct)
    % outputNoise = outputNoiseSetup(CMOstruct) creates a
    % [CMOstruct.numOuputs,1] array with random values in the set
    % (-maxNoise,maxNoise).
    outputNoise = 2*maxNoise*rand(CMOstruct.numOutputs,1,'double') - maxNoise;
end