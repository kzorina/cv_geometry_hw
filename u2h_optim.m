function [h_best, points] = u2h_optim(u1, u2)

v = 1:10;
C = nchoosek(v, 4);
min_error = Inf;
h_best = [];
points = [];

for i=1:size(C,1)
    H =  u2H(u1(:, C(i,:)),u2(:, C(i,:)));
    if isempty(H)
        continue;
    end
    u_hat = H*u1;
    u_hat(1, :) = u_hat(1, :)./u_hat(3, :);
    u_hat(2, :) = u_hat(2, :)./u_hat(3, :);
    
    errors = sqrt(sum((u2(1:2, :)-u_hat(1:2, :)).^2));
    error = max(errors);
    if error < min_error
        h_best = H;
        min_error = error;
        points = C(i,:);
    end
end

    
    
    