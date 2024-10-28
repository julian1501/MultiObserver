function eta = etaSetup(u,N,n,m,noiseFactor,noisePower)
    % This function defines the composite input/noise vector eta: [u; v;
    % w]. Where u is input, vi is sensor noise and w is process noise.
    % Inputs:
    %   - u: system input
    %   - n: number of states
    %   - m: number of outputs
    %   - k: number of system inputs = size(u,1)
    tsize = size(u,2);

    % Generate N (m x tsize) sensor noise signals
    v = noiseFactor*wgn(N*m,tsize,noisePower);

    % Generate an (n x tsize) process noise signal
    w = zeros(n*m,tsize);

    eta = [u;v;w];
end