function u_new = apply_homography(u, H)
x_hat = H(1,1)*u(1) + H(1,2)*u(2) + H(1,3);
y_hat = H(2,1)*u(1) + H(2,2)*u(2) + H(2,3);
denum = H(3,1)*u(1) + H(3,2)*u(2) + H(3,3);

x_hat = x_hat ./ denum;
y_hat = y_hat ./ denum;

u_new = [x_hat, y_hat];