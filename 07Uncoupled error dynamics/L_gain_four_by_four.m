 % --- Final Solver for L with poles at (s-x)^4 ---
  clear;
  clc;

  % Define all symbolic variables
  syms s lambda_c kc b l1 l2 l3 l4 lambda_e;

  % Define system matrices
  A_sym = [lambda_c -kc 0 -b*kc; 0 1 1 0; 0 0 1 0; 0 1 0 0];
  C_sym = [1 0 0 0];
  L_sym = [l1; l2; l3; l4];

  % Construct system characteristic polynomial
  poly_system = det(s*eye(4) - (A_sym - L_sym*C_sym));

  % Construct desired characteristic polynomial
  poly_desired = (s-lambda_e)^4;

  % Equate coefficients and solve
  coeffs_system = coeffs(poly_system, s);
  coeffs_desired = coeffs(poly_desired, s);
  equations = (coeffs_system(1:4) == coeffs_desired(1:4));
  solution = solve(equations, [l1, l2, l3, l4]);

  % Display the final formulas
  fprintf('--- Final Formulas for L ---\n\n');
  fprintf('l1 = \n'); pretty(solution.l1);
  fprintf('\nl2 = \n'); pretty(solution.l2);
  fprintf('\nl3 = \n'); pretty(solution.l3);
  fprintf('\nl4 = \n'); pretty(solution.l4);
  