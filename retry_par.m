%% use parfor for parallel computing
parpool

tic
num = 300
y = cell(num,1);
parfor i = 1:num    
    stuff = round(inv(rand(100)).*1000);
    b = [];
    for j = 1:1000
        bt = find(stuff==j);
        b = [b bt']; 
    end
    y{i} = b;
end
toc

delete(gcp('nocreate'))

%% compare with sequential
tic
num = 300
y = cell(num,1);
for i = 1:num    
    stuff = round(inv(rand(100)).*1000);
    b = [];
    for j = 1:1000
        bt = find(stuff==j);
        b = [b bt']; 
    end
    y{i} = b;
end
toc
