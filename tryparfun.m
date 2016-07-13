function y = tryparfun(num,obj)

y = cell(num,1);
parfor i = 1:num    
    stuff = round(inv(rand(100)).*obj);
    b = [];
    for j = 1:obj
        bt = find(stuff==j);
        b = [b bt']; 
    end
    y{i} = b;
end
