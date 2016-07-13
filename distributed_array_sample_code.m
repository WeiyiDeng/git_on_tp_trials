% w: Copied code from Mathwork Tutorial: Parallel and GPU Computing with MATLAB (8 of 9): Distributed Arrays
%% Use matrix creation functions
T = rand(4, 4, 'distributed')

spmd
    disp(getLocalPart(T))
end

%% Distribute array to workers
% Create array on client
A = reshape(1:32, 4, 8);

% Distribute the array so that each worker has 
% selected columns only
A = distributed(A)
spmd
    disp(getLocalPart(A))
end

%% Create distributed array from small pieces on different workers
spmd
    N = 1; % also try with larger N
    mat = repmat([1;2;3], 1, N) + (labindex-1)*3;
    
    codistr = codistributor1d( ...
            codistributor1d.unsetDimension, ...
            codistributor1d.unsetPartition, ...
            [3, numlabs*N]);
    distmat = codistributed.build(mat, codistr)
    
    disp(getLocalPart(distmat))
end

%% Compute sum and collect ("gather") data
distsum = sum(distmat);
numericsum = gather(distsum) 


% Copyright 2014 The MathWorks, Inc.