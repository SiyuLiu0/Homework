clc
clear all

%optimize over power allocation and receiver filter coefficients
% parameter settings
np = 6.3611 * 10^(-13);
p_p = 0.2 / np;
rou = p_p;
tau_training = 20;
tau_c = 200;
K = 20;
M = 130;
phi = zeros(tau_training, K);
distance = zeros(M, K);
d0 = 0.01;
d1 = 0.05;
f = 1900;
h_ap = 15;
h_k = 1.65;
limit=0.01; 
[U,S,V]=svd(normrnd(0,1,[tau_training, tau_training]));
z= normrnd(0,1,[M,K]);
beta = zeros(M, K);
gamma = zeros(M, K);
c = zeros(M, K);
L = 46.3+33.9*log10(f)-13.82*log10(h_ap)-(1.1*log10(f)-0.7)*h_k-(1.56*log10(f)-0.8);

n = 150;
gp_opt = zeros(1,n);
bs_opt = gp_opt;

for test = 1:n

r = randi([1 tau_training], 1, K);
for i=1:K
    phi(:,i) = U(:,r(i));
end

% distance computation, based on the settings in [1] and [2]
users = zeros(K, 2, 9);
AP = zeros(M, 2, 9);
users(:, :, 1) = unifrnd(0, 1, K, 2);
AP( :, :, 1) = unifrnd(0, 1, M, 2);
x = [0; -1; 1];
for i = 1:3
    for j = 1:3
        if x(i) ~= 0 || x(j) ~= 0
            extra = zeros(K, 2);
            extra(:, 1) = x(i) * ones(K, 1);
            extra(:, 2) = x(j) * ones(K, 1);
            users(:, :, 3 * (i - 1) + j) = users(:, :, 1) + extra;
            extra = zeros(M, 2);
            extra(:, 1) = x(i) * ones(M, 1);
            extra(:, 2) = x(j) * ones(M, 1);
            AP(:, :, 3 * (i - 1) + j) = AP(:, :, 1) + extra;
        end
    end
end

for i = 1:M
    for j = 1:K
        distance(i, j) = norm(AP(i, :, 1) - users(j, :, 1));
        for k = 2:9
            thisd = norm(AP(i, :, k) - users(j, :, k));
            if thisd < distance(i, j)
                distance(i, j) = thisd;
            end
        end
    end
end

for i = 1:M
    for j = 1:K
        if distance(i, j) < d0
           beta(i, j) = (-L - 15 * log10(d1) - 20 * log10(d0));
        elseif distance(i, j) > d1
            beta(i, j) = (-L - 35 * log10(distance(i, j))) + z(i, j);
        else
            beta(i, j) = (-L - 15 * log10(d1) - 20 * log10(distance(i, j)));
        end
        beta(i, j) = 10^(beta(i, j)/10); 
    end
end

for i = 1:M
    for j = 1: K
        c(i, j) = (beta(i, j) *(tau_training * p_p)^(1/2))/(1 + tau_training * p_p * (norm( (beta(i,:).^(1/2)).*(phi(:,j)'* phi))^2));
        gamma(i, j) = (beta(i, j) *(tau_training * p_p)^(1/2))* c(i, j);
    end
end

e = zeros(K, K);
f = zeros(K, K);
r = zeros(1, K);
d = zeros(1, K);
for i = 1:K
    r(i) = sum(gamma(:, i));
    d(i) = (r(i)).^2;
    for j = 1: K
        e(i, j) = sum(gamma(:,i)./beta(:,i).*beta(:,j))^2 * norm(phi(:,i)' * phi(:,j))^2;
        f(i, j) = sum(beta(:,j).* gamma(:,i));
    end
end

lastt = -0.5;
t = 0;
q = ones(K, 1);
while abs(lastt - t) > 0.01
% GP - sub-optimal solution
u = zeros(M, K);
R = zeros(M, M, K);
Nphi = zeros(K, K);
delta = zeros(K, M, K);

for k = 1:K
    D = zeros(M, M);
    R(:, :, k) = diag(gamma(:, k));
    dkk = zeros(M, M);
for i = 1:K
    Nphi(k, i) = norm(phi(:,k)' * phi(:,i))^2;
    D = D + q(i) * diag(beta(:, i).*gamma(:, k)); %D1k'
    delta(i, :, k) = beta(:, i).*gamma(:, k)./beta(:, k);
    if i ~= k
        dkk = dkk +q(i) * Nphi(k, i) * (delta(i, :, k)' * delta(i, :, k));
    end
end
A = gamma(:, k) * gamma(:, k)';
B = dkk + D + (R(:, :, k))/rou;
[V,T] = eig(q(k) * A,B);
 
u(:,k) = V(:, M) * (1/norm(V(:, M)));
end

lastt = t;
cvx_begin gp quiet
              variables x(K, 1) t
              maximize t
              subject to
                for k=1:K
                    D = zeros(M, M, K);
                    A = gamma(:, k) * gamma(:, k)';
                for i = 1:K
                    D(:, :, i) = diag(beta(:, i).*gamma(:, k)); %D1k'
                end
                d = u(:,k)' * A * u(:,k);
                a = zeros(K, K);
                b = zeros(K, K);
                o = zeros(1, K);
                o(k) = u(:,k)' * R(:, :, k) * u(:,k)/d;
                for i = 1:K
                    a(k, i) = u(:,k)' * (Nphi(k,i)* delta(i, :, k)'*delta(i, :, k)) * u(:,k)/d; 
                    b(k, i) = u(:,k)' * D(:, :, i) * u(:,k)/d;
                end
                x(k)>=0;
                x(k)<=1;
                (1/x(k)) * ([a(k,1:(k-1)), a(k,(k+1):K)]*[x(1:(k-1)); x((k+1):K)] + (b(k,:)*x) + o(k)/rou) <= 1/t;
                end 
cvx_end
q = x;
end
gp_opt(test) = log2(1 + t);
test

end
cdfplot(gp_opt)
title('');
xlabel('Min uplink rate (bits/s/Hz)');
ylabel('Cumulative distribution');
legend('Optimize over u and q','Location','best')