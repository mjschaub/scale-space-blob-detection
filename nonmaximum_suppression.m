function center_result = nonmaximum_suppression(x)
%disp(x);
[m, n] = size(x);
%disp([m n]);
if m == 3
    center = 5;
elseif m == 5
    center = 13;
elseif m == 9
    center = 41;
end

if x(center) >= max(x(:))
    center_result = x(center);
else
    center_result = 0;
end
