clear all
% job = batch('trypar')             % for script (m file)
% job = batch(@tryparfun, 1, {300,1000});        % use function
% w: inside the {} are the input values for the function

%% Submit batch job
clust = parcluster('local');      % w: does not seem necessary, job opens clust directly?
N = 4; % for a 6-core computer
% To utilize all available workers on a cluster 
% of multiple computers, use the following instead:
% N = clust.NumIdleWorkers;
job = batch(clust, @tryparfun, 1, {300, 1000}, 'Pool', N-1);
% job = batch(@tryparfun, 5, {300, 1000});              % w: not work, why ??
% job = batch('trypar', 'configuration', 'local', 'matlabpool', 5);

%% Query state of job
get(job, 'State')

%% Wait for job to be finished
% If you run the script using the "Run" button or from the command line,
% the above section may return a state different from 'finished' and resume
% with the next section, thus making fetchOutputs throw an error.
% The following line is inserted to ensure that the job is really finished 
% before proceeding to fetch the outputs from it:
wait(job, 'finished')
% load(job)

%% Retrieve and process results
% (after job has reached 'finished' state)
results = fetchOutputs(job);
% results = getAllOutputArguments(job);
a = results{1};
% hist(a)

%% Delete job
delete(job)
% clear job


% % --------
% % Get cluster information
% clust = parcluster('local');
% 
% % Setting up a job
% job = createJob(clust);
%  
% tic
% % Creation of multiple tasks which are each sent to 1 worker, 
% for N = 1:4
%     % createTask(job, @task, #outputs, {inputs(N)})
%     createTask(job, @tryparfun, 1, {N*100, 1000});
% end
% % (alternatively any sequence of createTask commands)
% 
% % Submit job, wait for it to be finished and retrieve results
% submit(job);
% wait(job, 'finished');
% results = fetchOutputs(job);
% toc
% 
% % Destroy the job
% delete(job);