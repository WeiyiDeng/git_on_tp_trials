function loglikelihood=f_loglikelihood_assignment(B);

global Y  X n_brands

%% utility
utility         = sum( X .*  repmat(B,size(X,1),1),2);  %compute utility

%% likelihood
utility         =reshape(utility,n_brands,[]);          %reshaping utility from vector to matrix, it makes next line easier and shorter
likelihood      =exp(utility)./ repmat(sum(exp(utility)),n_brands,1);  % Logit likelihood
likelihood      =reshape(likelihood,[],1);              
%% Loglikelihood
likelihood(Y==0)        =[];
loglikelihood           =log(likelihood);               % summing up log-likelihoods. Log is not necessary but helps with numerical issues at times. It also results in more weight being attached to observations with very low probability
loglikelihood           =-sum(loglikelihood);           % minus sign is because optimization engine, fminunc, minimizes while we search for a maximum likelihood