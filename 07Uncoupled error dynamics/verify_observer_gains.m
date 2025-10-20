clear; clc;
%% 
lambda_c = 0.9391
lambda_e = 0.7304
b = 0.9782
beta = sqrt(lambda_c * lambda_e)
kc = (1 - lambda_c) / (1 + b)
%% 
l1 = lambda_c + (1 + beta) - 3*lambda_e

l2 = (b*(lambda_e - 1)^3 - beta*(b + 1)*(beta^2 - 3*beta*lambda_e + beta + 3*lambda_e^2 - 3*lambda_e + 1)) / ...
     (kc * (b + 1) * (b + beta))

l3 = (-beta - b - beta*b + 3*beta*lambda_e + 3*b*lambda_e - beta^2*b - 3*b*lambda_e^2 - beta^2 - lambda_e^3 + 3*beta*b*lambda_e) / ...
     (kc * (b + 1) * (b + beta))
%%
A = [lambda_c-l1,  -kc,      -b*kc;
     -l2,         beta+1,   -beta;
     -l3,         1,         0    ]
%%
lambda = eig(A);

for i = 1:length(lambda)
    fprintf('  lambda %d = %.10f\n', i, lambda(i));
end

errors = lambda - lambda_e;
for i = 1:length(errors)
    fprintf('  error %d = %.2e\n', i, errors(i));
end
max_error = max(abs(errors))