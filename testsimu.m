n = 100;

X = randn(n,2);
epsilon = randn(n,1);

groups = randn(n,1);
D1 = groups<0.3;
D2 = groups>0.3;

% for the first variable beta==5 for group 1 and beta==2 for group 2
% in the data generation process
y = X(:,1).*D1*5+X(:,2)*3+epsilon;
y = y + X(:,1).*D2*2;

b = inv(X'*X)*X'*y

% or use
% b = X\y;

% run model(2) in Ectrics2 Lec 7 Slide 10
X1 = repmat(D1,1,2).*X;
X2 = repmat(D2,1,2).*X;

b_2 = [X1 X2]\y

% run model(3)
b_3 = [X1 X]\y

% run separate regressions
X_group1 = X(D1,:);
X_group2 = X(D2,:);
y_group1 = y(D1,:);
y_group2 = y(D2,:);
b_group1 = X_group1\y_group1
b_group2 = X_group2\y_group2

