function [val, num] = toyfunc(n)

val = [];
for i=1:n
    val(i) = i^2;
end

num = n^2;

end