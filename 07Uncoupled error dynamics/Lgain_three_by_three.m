 % --- Final Solver for L with poles at (s-x)^4 ---
  clear;
  clc;

  % Define all symbolic variables
  syms s lambda_c kc b l1 l2 l3 l4 B lambda_e;

  % Define system matrices
  A_sym = [lambda_c -kc  -b*kc; 0 B+1 -B; 0  1 0];
  C_sym = [1 0 0 ];
  L_sym = [l1; l2; l3];

  % Construct system characteristic polynomial
  poly_system = det(s*eye(3) - (A_sym - L_sym*C_sym));

  % Construct desired characteristic polynomial
  poly_desired = (s-lambda_e)^3;

  % Equate coefficients and solve
  coeffs_system = coeffs(poly_system, s);
  coeffs_desired = coeffs(poly_desired, s);
  equations = (coeffs_system(1:3) == coeffs_desired(1:3));
  solution = solve(equations, [l1, l2, l3]);

  % Display the final formulas
  fprintf('--- Final Formulas for L ---\n\n');
  fprintf('l1 = \n'); pretty(solution.l1);
  fprintf('\nl2 = \n'); pretty(solution.l2);
  fprintf('\nl3 = \n'); pretty(solution.l3);
  
  