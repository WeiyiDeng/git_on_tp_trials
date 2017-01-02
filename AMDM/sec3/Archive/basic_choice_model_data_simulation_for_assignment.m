clear; clc;                         % clear workspace variables and command window; 
tic;                                % start counting time
global Y X n_brands                 % declare which variables should be available to other scripts, in this case we need f_loglikelihood_assignment.m to access these variables


%% setup 
n_brands           	= 2;                        %these are my arbitrary choices, other variable names and/or numbers would be fine as well 
n_choices_pp    	= 100;
n_people          	= 100;
n_choices         	=n_choices_pp*n_people;

%% parameters
% slope coefficient 
B_constant         	=1*(1:n_brands-1);          %these are my arbitrary choices, other variable names and/or numbers would be fine as well 
B_last_purchase   	=2;
B_price         	=1;
B_feature_display   =.5;

% mean and standard deviation of variables we will generate
price_mean         	=[7 6];                     % there are 2 values because for now we have 2 brands; if you change number of brands, you need to change number of values here
price_SD          	=[.2 .4];
feature_display_mean=[6 8];
feature_display_SD 	=[.2 .3];

%% DATA SIMULATION
%% OV - organizing variables generation
O_obs_numb          =reshape((repmat((1:n_choices)',1,n_brands))',[],1);    %this variable will be included 
                                                                            %in the data but it is not dependent or indipendent variable; 
                                                                            % just organizing variable indicating number of the observation
                                                                            % The data are set up such that for every observation there are as many rows as there are choice alternatives/brands                                                                           
O_choice_alt        =reshape(repmat((1:n_brands)',n_choices,1),[],1);       % Number of the choice alternative; 
O_person            =reshape(repmat((1:n_people),n_choices_pp*n_brands,1),[],1); %Number of the person;
                    % after running this script, mouse over these three
                    % organizing variables to see what values they have.
                    % Alternatively you can type their name e.g. O_obs_numb to the
                    % Command Window.                    

%% IV simulation
%% generating values of IVs
% constants
X_constant          =zeros(n_choices*n_brands,n_brands-1);   %Constant variable, also called dummy, is 1 for one brand, 0 for other brands
for j=2:n_brands
    temp          	=zeros(n_choices,n_brands);
    temp(:,j)       =1;
    X_constant(:,j-1)	= reshape(temp',[],1);
end
% last purchase
X_Last_purchase     =zeros(n_choices*n_brands,n_brands-1);  %For now this variable is all zeros, we will change that later
% price
X_price             =(randn(n_choices,n_brands).*repmat(price_SD,n_choices,1))+repmat(price_mean,n_choices,1); %We draw standard random normal 
                    % variable, and, based on the preferences we
                    % specificied ourselves earlier, add mean and multiply
                    % by standard deviation. 
                    % READ THIS LIVE OF CODE AREFULLY. You can crease your
                    % own random variable by pasting (rand(100,1)*5)+6 into
                    % Command Window. This will crease random normal
                    % variable with mean 6 and and standard deviation 5
                    
X_price             =reshape(X_price',[],1);
% feature & display
X_feature_display   =(randn(n_choices,n_brands).*repmat(feature_display_SD,n_choices,1))+repmat(feature_display_mean,n_choices,1);
                    % feature&display is a promotion variable: indicates
                    % when there was more features: mentions of brand in
                    % printed leaflet of the retailer; display is measure
                    % of brand receiving preferentiall display in store,
                    % e.g. end of alley display or on-shelf flag or so. 
X_feature_display             =reshape(X_feature_display',[],1);

%% putting OVs and IVs into one matrix & creating one variable name vector
O                 	=[O_obs_numb O_choice_alt O_person]; %These are names of variables
O_names            =[{'Obs number'} {'Alt'} {'Person'}];

B                   =[B_constant B_last_purchase B_price B_feature_display];
X_names             =[{'Constant for B'} {'Last_purchase'} {'Price'} 'Feature&Display'];

%% Simulating DV
choice_draws        =reshape(repmat(rand(1,n_choices),n_brands,1),[],1) ;   %random draws which will be used to 
                                                                            % determine whether brand was chosen
Y                   =zeros(n_choices*n_brands,1);  % empty dependent variable
%% choice draws
for i=1:n_people %for every person in the virtual sample
    pers_obs                =O_person==i;       %identify observations belonging to this person
    first_obs_for_person_i  =min(O_obs_numb(pers_obs)); %identify first obs of given person
    last_obs_for_person_i  =max(O_obs_numb(pers_obs));  %identify last obs of given person
    for t=first_obs_for_person_i:last_obs_for_person_i  % for all observations from first to last of a given person do what follows     
        X                   =[X_constant X_Last_purchase X_price X_feature_display];  % put together all independent variables into one X matrix
        rows_for_obs_t      =find(O_obs_numb==t);       % identify rows for this observation
        %% utility
        utility             = X(rows_for_obs_t,:) *  B';%compute utility, simply X variables times sensitivity parameters B
                                                        % READ THIS LINE CAREFULLY
        
        %% likelihood
        for j=1:n_brands
            likelihood      =exp(utility) / sum(exp(utility) ); % Logit expression for likelihood 
        end
        
        %% simmulated choices
        Y(rows_for_obs_t)   =choice_draws(rows_for_obs_t)<cumsum(likelihood) & choice_draws(rows_for_obs_t)>[0; cumsum(likelihood(1:n_brands-1))];
                                        % the above line is when we simulate choice. We sum
                                        % likelihoods cumulatively (type "cumsum([.1, .1, .1]) into command window to learn what it means).
                                        % READ THIS LINE CAREFULLY, TRY TO UNDERSTAND IT
                                        % the choice of the first brand is made if random draw
                                        % is between 0 and it's likelihood. Second brand is chosen if random
                                        % draw is larger than likelihood of the first brand and lower than
                                        % the likelihood of the first and second brand combined. 
        if t~=last_obs_for_person_i
            X_Last_purchase(max(rows_for_obs_t)+1:max(rows_for_obs_t)+n_brands) = Y(rows_for_obs_t);
                                        % Now we come back to last purchase variable. It equals 1 if given
                                        % brand was chosen last time, 0 otherwise. Note that, unline with
                                        % price variable, we could not simulate this variable ealier, we
                                        % first need to simulate choice
        end
    end
end
%% putting all data into one file
DATA.data               =[Y O X];       % creating one nice variable with data
DATA.names              =['Choice' O_names X_names];  % adding names to the same variable but different field

% DATA IS SIMULATED :)

% sum(reshape(Y,2,[]),2);


%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%% PARAMETER ESTIMATION
%% Data
Y=DATA.data(:,1);                       % I begin as I would with non-simulated data: I parse the data into relevant blocks: DV
O=DATA.data(:,2:4);                     % organizational variables
X=DATA.data(:,5:end);                   % IVs

n_people            = length(unique(O(:,3)));   % With non-simulated data I would also need to establish number of people, ..
n_obs               = length(unique(O(:,1)));   % observations, ...
n_brands            = length(unique(O(:,2)));   % and brands
%% Parameter starting values
B_constant          = 1+zeros(n_brands-1);      % This is the first guess the sript makes about value of coefficients. 
B_last_purchase     = 2;                        % You can check what would happen if you selected really far-off values, eg -1000
B_price             = 3;
B_feature_display   = 4;

%% all parameters vector
B                   =[B_constant B_last_purchase B_price B_feature_display];


%% estimation method 1 using gradient based approach
% MaxFunEvals     =20000;
% MaxIter         =5000; 
MaxFunEvals     =[];
MaxIter         =[];
TolX            =[];
TolFun          =[];

options=optimset('Display','iter', 'Hessian','off', 'MaxFunEvals',MaxFunEvals,'MaxIter',MaxIter,'TolX',TolX,'TolFun',TolFun,'DerivativeCheck','off');
                                            % the line above passes estimation preferences to the minimization script 
% actual estimation
[B_hat,fval,exitflag,output,grad,hessian]=fminunc(@f_loglikelihood_assignment,B,options);
                                            % READ THIS LINE CAREFULLY: you are asking scipt fminunc to
                                            % minimize function f_loglikelihood_assignment by changing values in vector B
                                            % on the left we have many outputs but B_hat is most important, these are the estimates

%% estimation method 2 using pattern search
% options=optimset('Display','iter','MaxFunEvals',MaxFunEvals,'MaxIter',MaxIter,'TolX',TolX,'TolFun',TolFun);       % this method is not used to
% begin with. To use it, remove % from the beginning of the line and add % to all lines associated with method 1
% [B_hat,fval,exitflag,output]=patternsearch(@f_loglikelihood_assignment,B,[],[],[],[],[],[],options);


if exitflag==0
    error('No convergence')
end

%Calculate standard errors of parameters
if exist('hessian')                         % computing standard errors of the estimates
    disp('');disp('Taking inverse of hessian for standard errors.');
    ihess=inv(hessian);
    stderr=sqrt(diag(ihess));
else
    stderr=nan*B_hat;
end

%% displaying estimation results
disp(' ');disp(' ');
disp('');disp('Parameter estimates');

output = cell2table(X_names');
output.Properties.VariableNames= {'Variable_name' };
output.Estimate = B_hat';
output.SD       = stderr;
output
toc;