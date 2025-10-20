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
  
%% ========== Verification: L2 and L3 ==========
fprintf('\n========== VERIFICATION (L2 & L3) ==========\n');

% Define manual formulas
l2_manual = (b*(lambda_e - 1)^3 - B*(b + 1)*(B^2 - 3*B*lambda_e + B + 3*lambda_e^2 - 3*lambda_e + 1)) / (kc * (b + 1) * (b + B));

% Original (incorrect):
% l3_manual = (-(b + B)*(B^2 - 3*B*lambda_e + B + 3*lambda_e^2 - 3*lambda_e + 1) - lambda_e^3) / (kc * (b + 1) * (b + B));

% Corrected formula based on solver output analysis:
l3_manual = (-B - b - B*b + 3*B*lambda_e + 3*b*lambda_e - B^2*b - 3*b*lambda_e^2 - B^2 - lambda_e^3 + 3*B*b*lambda_e) / (kc * (b + 1) * (b + B));

% --- Verify L2 ---
fprintf('\n=== L2 Verification ===\n');
diff_l2 = simplify(l2_manual - solution.l2);
fprintf('Difference (simplified): ');
pretty(diff_l2);

if diff_l2 == 0
    fprintf('✓ PASS: l2_manual = solution.l2\n');
else
    fprintf('✗ FAIL: l2_manual ≠ solution.l2\n');
end

% --- Verify L3 ---
fprintf('\n=== L3 Verification ===\n');
fprintf('Manual formula:\n');
pretty(l3_manual);

fprintf('\nSolver solution:\n');
pretty(solution.l3);

diff_l3 = simplify(l3_manual - solution.l3);
fprintf('\nDifference (simplified):\n');
pretty(diff_l3);

if diff_l3 == 0
    fprintf('✓ PASS: l3_manual = solution.l3\n');
else
    fprintf('✗ FAIL: l3_manual ≠ solution.l3\n');

    % Additional analysis for l3
    fprintf('\n--- Debugging L3 ---\n');
    fprintf('Trying to expand and collect terms...\n');

    % Expand both expressions
    l3_manual_expanded = expand(l3_manual);
    l3_solver_expanded = expand(solution.l3);

    fprintf('\nManual (expanded):\n');
    pretty(l3_manual_expanded);

    fprintf('\nSolver (expanded):\n');
    pretty(l3_solver_expanded);

    % Try simplifying the difference with different methods
    fprintf('\nDifference (expanded then simplified):\n');
    diff_expanded = simplify(expand(diff_l3));
    pretty(diff_expanded);
end

fprintf('\n========== END VERIFICATION ==========\n');