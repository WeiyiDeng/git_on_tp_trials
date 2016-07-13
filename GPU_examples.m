% wtry
% check out gpu status
gpuDeviceCount()
gpu = parallel.gpu.GPUDevice.getDevice(1)

% reset(gpuDevice);                  % w: use this to release memory from GPU !!

% create array on GPU
tryGPU = randn(10,10,'gpuArray')

whos tryGPU

% or 
T = zeros(5,5)
T = gpuArray(T)
whos T

%% Filter a matrix on CPU
A = magic(8000);
f = ones(1,20)/20;

tic;
B = filter(f, 1, A);
tCPU = toc;

disp(['Total time on CPU:       ' num2str(tCPU)])

%% Filter a matrix on GPU
tic;
AonGPU = gpuArray(A);
BonGPU = filter(f, 1, AonGPU);
BonCPU = gather(BonGPU);
wait(gpuDevice)
tGpu = toc;

disp(['Total time on GPU:       ' num2str(tGpu)])

% try?
A = gather(AonGPU)

%% Look at computation time only
tic;
BonGPU = filter(f, 1, AonGPU);
wait(gpuDevice)
tCompGpu = toc;

disp(['Computation time on GPU: ' num2str(tCompGpu)])


% Copyright 2014 The MathWorks, Inc.


%% pagefun example below
%% settings
M = 300;       % output number of rows
K = 800;       % matrix multiply inner dimension
N = 100;       % output number of columns
P = 200;       % number of pages

%% CPU code
tic
A = rand(M,K);   
B = rand(K,N,P);
C = zeros(M,N,P);
for I=1:P
    C(:,:,I) = A * B(:,:,I);
end
t = toc;
disp(['CPU time: ' num2str(t)])

%% equivalent GPU code
tic
A = rand(M,K,'gpuArray');   
B = rand(K,N,P,'gpuArray');
C2 = zeros(M,N,P,'gpuArray');
for I=1:P
    C2(:,:,I) = A * B(:,:,I);
end
wait(gpuDevice)
t = toc;
disp(['GPU, using gpuArrays: ' num2str(t)])

%% improved GPU code
tic
A = rand(M,K,'gpuArray');   
B = rand(K,N,P,'gpuArray');
C3 = pagefun(@mtimes,A,B);
wait(gpuDevice)
t = toc;
disp(['GPU, using pagefun: ' num2str(t)])

reset(gpuDevice);                  % w: use this to release memory from GPU !!

% Copyright 2014 The MathWorks, Inc.