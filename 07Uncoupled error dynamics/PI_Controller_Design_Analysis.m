%% PI Controller Design and Stability Analysis
% System: H(s) = 1.1592e7 / (s^2 + 6.6172e3*s + 1.1592e7)
% Goal: Design PI controller and analyze stability region

clear; close all; clc;

%% ========================================================================
%  Part 1: Define Original System H(s)
%% ========================================================================
num_H = 1.1592e7;
den_H = [1, 6.6172e3, 1.1592e7];
H = tf(num_H, den_H);

fprintf('========================================\n');
fprintf('Original System H(s):\n');
fprintf('========================================\n');
tf(H)

% Extract system parameters
wn = sqrt(1.1592e7);  % Natural frequency
zeta = 6.6172e3 / (2*wn);  % Damping ratio
fprintf('Natural frequency ωn = %.4f rad/s\n', wn);
fprintf('Damping ratio ζ = %.4f\n', zeta);
fprintf('\n');

%% ========================================================================
%  Part 2: Baseline Performance - Unity Feedback (No Controller)
%% ========================================================================
fprintf('========================================\n');
fprintf('BASELINE: Unity Feedback (No Controller)\n');
fprintf('========================================\n');

% Closed-loop transfer function: T(s) = H(s)/(1 + H(s))
T_baseline = feedback(H, 1);

fprintf('Closed-loop transfer function T(s) = H(s)/(1+H(s)):\n');
tf(T_baseline)

% Poles and zeros
poles_baseline = pole(T_baseline);
zeros_baseline = zero(T_baseline);
fprintf('Closed-loop poles:\n');
disp(poles_baseline);

% Step response analysis
figure('Name', 'Baseline Performance - Unity Feedback', 'Position', [100, 100, 1200, 800]);

subplot(2,3,1);
step(T_baseline);
title('Baseline: Step Response');
grid on;

% Get step info
step_info_baseline = stepinfo(T_baseline);
fprintf('\nStep Response Characteristics:\n');
fprintf('  Rise Time: %.6f s\n', step_info_baseline.RiseTime);
fprintf('  Settling Time: %.6f s\n', step_info_baseline.SettlingTime);
fprintf('  Overshoot: %.4f %%\n', step_info_baseline.Overshoot);
fprintf('  Peak: %.4f\n', step_info_baseline.Peak);
fprintf('  Peak Time: %.6f s\n', step_info_baseline.PeakTime);

% Frequency response (Bode plot)
subplot(2,3,2);
margin(T_baseline);
title('Baseline: Bode Diagram');
grid on;

% Get stability margins
[Gm_baseline, Pm_baseline, Wgm_baseline, Wpm_baseline] = margin(T_baseline);
fprintf('\nFrequency Domain Characteristics:\n');
fprintf('  Gain Margin: %.4f dB (at %.4f rad/s)\n', 20*log10(Gm_baseline), Wgm_baseline);
fprintf('  Phase Margin: %.4f deg (at %.4f rad/s)\n', Pm_baseline, Wpm_baseline);

% Nyquist plot
subplot(2,3,3);
nyquist(T_baseline);
title('Baseline: Nyquist Diagram');
grid on;

% Pole-zero map
subplot(2,3,4);
pzmap(T_baseline);
title('Baseline: Pole-Zero Map');
grid on;

% Impulse response
subplot(2,3,5);
impulse(T_baseline);
title('Baseline: Impulse Response');
grid on;

% Root locus (for reference)
subplot(2,3,6);
rlocus(H);
title('Baseline: Root Locus of H(s)');
grid on;

fprintf('\n');

%% ========================================================================
%  Part 3: PI Controller - Routh-Hurwitz Stability Analysis
%% ========================================================================
fprintf('========================================\n');
fprintf('PI CONTROLLER STABILITY ANALYSIS\n');
fprintf('========================================\n');

% PI Controller: C(s) = Kp + Ki/s = (Kp*s + Ki)/s
% Closed-loop characteristic equation: 1 + C(s)*H(s) = 0
%
% C(s)*H(s) = [(Kp*s + Ki)/s] * [1.1592e7 / (s^2 + 6.6172e3*s + 1.1592e7)]
%           = [1.1592e7*(Kp*s + Ki)] / [s*(s^2 + 6.6172e3*s + 1.1592e7)]
%
% 1 + C(s)*H(s) = 0
% s*(s^2 + 6.6172e3*s + 1.1592e7) + 1.1592e7*(Kp*s + Ki) = 0
% s^3 + 6.6172e3*s^2 + 1.1592e7*s + 1.1592e7*Kp*s + 1.1592e7*Ki = 0
% s^3 + 6.6172e3*s^2 + (1.1592e7 + 1.1592e7*Kp)*s + 1.1592e7*Ki = 0
% s^3 + 6.6172e3*s^2 + 1.1592e7*(1 + Kp)*s + 1.1592e7*Ki = 0

fprintf('Characteristic equation:\n');
fprintf('s^3 + 6.6172e3*s^2 + 1.1592e7*(1 + Kp)*s + 1.1592e7*Ki = 0\n\n');

% Coefficients: a3*s^3 + a2*s^2 + a1*s + a0 = 0
% a3 = 1
% a2 = 6.6172e3
% a1 = 1.1592e7*(1 + Kp)
% a0 = 1.1592e7*Ki

fprintf('Routh-Hurwitz Table:\n');
fprintf('s^3 |  1              1.1592e7*(1+Kp)\n');
fprintf('s^2 |  6.6172e3       1.1592e7*Ki\n');
fprintf('s^1 |  b1             0\n');
fprintf('s^0 |  c1             0\n\n');

fprintf('where:\n');
fprintf('b1 = [6.6172e3 * 1.1592e7*(1+Kp) - 1 * 1.1592e7*Ki] / 6.6172e3\n');
fprintf('   = 1.1592e7*(1+Kp) - 1.1592e7*Ki/6.6172e3\n');
fprintf('   = 1.1592e7*[(1+Kp) - Ki/6.6172e3]\n\n');
fprintf('c1 = 1.1592e7*Ki\n\n');

fprintf('Stability Conditions (Routh-Hurwitz):\n');
fprintf('All coefficients must be positive:\n');
fprintf('1. a3 = 1 > 0  ✓ (always satisfied)\n');
fprintf('2. a2 = 6.6172e3 > 0  ✓ (always satisfied)\n');
fprintf('3. a1 = 1.1592e7*(1+Kp) > 0  →  Kp > -1\n');
fprintf('4. a0 = 1.1592e7*Ki > 0  →  Ki > 0\n');
fprintf('5. b1 > 0  →  (1+Kp) - Ki/6.6172e3 > 0\n');
fprintf('              →  Ki < 6.6172e3*(1+Kp)\n');
fprintf('6. c1 > 0  →  Ki > 0 (same as condition 4)\n\n');

fprintf('Summary of Stability Conditions:\n');
fprintf('├─ Kp > -1\n');
fprintf('├─ Ki > 0\n');
fprintf('└─ Ki < 6.6172e3*(1+Kp)\n\n');

%% ========================================================================
%  Part 4: Plot Kp-Ki Stability Region
%% ========================================================================
fprintf('========================================\n');
fprintf('PLOTTING Kp-Ki STABILITY REGION\n');
fprintf('========================================\n');

% Define range for plotting
Kp_range = linspace(-1.5, 5, 1000);

% Stability boundaries
Ki_lower = zeros(size(Kp_range));  % Ki > 0
Ki_upper = 6.6172e3 * (1 + Kp_range);  % Ki < 6.6172e3*(1+Kp)

% Filter valid region (Kp > -1)
valid_idx = Kp_range > -1;

figure('Name', 'PI Controller Stability Region', 'Position', [150, 150, 1000, 800]);

% Plot stability boundaries
hold on;
fill([Ki_lower(valid_idx), fliplr(Ki_upper(valid_idx))], ...
     [Kp_range(valid_idx), fliplr(Kp_range(valid_idx))], ...
     [0.8, 0.95, 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5);

plot(Ki_upper(valid_idx), Kp_range(valid_idx), 'r-', 'LineWidth', 2, 'DisplayName', 'Ki = 6617.2(1+Kp)');
plot(Ki_lower(valid_idx), Kp_range(valid_idx), 'b-', 'LineWidth', 2, 'DisplayName', 'Ki = 0');

% Add horizontal line at Kp = -1
yline(-1, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Kp = -1');

% Labels and formatting
xlabel('Ki (Integral Gain)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Kp (Proportional Gain)', 'FontSize', 12, 'FontWeight', 'bold');
title('PI Controller Stability Region (Routh-Hurwitz Criterion)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
legend('Stable Region', 'Upper Boundary: Ki = 6617.2(1+Kp)', 'Lower Boundary: Ki = 0', 'Left Boundary: Kp = -1', ...
       'Location', 'northwest', 'FontSize', 10);

% Add text annotation
text(15000, 2.5, 'STABLE REGION', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0, 0.5, 0]);
text(15000, 2.0, 'Kp > -1', 'FontSize', 11);
text(15000, 1.6, 'Ki > 0', 'FontSize', 11);
text(15000, 1.2, 'Ki < 6617.2(1+Kp)', 'FontSize', 11);

xlim([0, 40000]);
ylim([-1.2, 5]);
hold off;

fprintf('Stability region plotted successfully!\n');
fprintf('Green shaded area represents stable Kp-Ki combinations.\n\n');

%% ========================================================================
%  Part 5: Test Specific PI Controller Designs
%% ========================================================================
fprintf('========================================\n');
fprintf('TESTING SPECIFIC PI CONTROLLER DESIGNS\n');
fprintf('========================================\n');

% Define test points
test_points = [
    0.1,  1000;   % Conservative
    0.5,  5000;   % Moderate
    1.0,  10000;  % Aggressive
    2.0,  15000;  % More aggressive
];

figure('Name', 'PI Controller Performance Comparison', 'Position', [200, 200, 1400, 900]);

for i = 1:size(test_points, 1)
    Kp_test = test_points(i, 1);
    Ki_test = test_points(i, 2);

    fprintf('\n--- Test Point %d: Kp = %.2f, Ki = %.2f ---\n', i, Kp_test, Ki_test);

    % Check stability
    is_stable = (Kp_test > -1) && (Ki_test > 0) && (Ki_test < 6.6172e3*(1+Kp_test));

    if is_stable
        fprintf('Status: STABLE ✓\n');
    else
        fprintf('Status: UNSTABLE ✗\n');
        continue;
    end

    % Create PI controller
    C_PI = tf([Kp_test, Ki_test], [1, 0]);

    % Closed-loop system
    T_PI = feedback(C_PI * H, 1);

    % Poles
    poles_PI = pole(T_PI);
    fprintf('Closed-loop poles:\n');
    disp(poles_PI);

    % Step response info
    try
        step_info_PI = stepinfo(T_PI);
        fprintf('Rise Time: %.6f s\n', step_info_PI.RiseTime);
        fprintf('Settling Time: %.6f s\n', step_info_PI.SettlingTime);
        fprintf('Overshoot: %.4f %%\n', step_info_PI.Overshoot);
        fprintf('Peak: %.4f\n', step_info_PI.Peak);
    catch
        fprintf('Could not compute step info (possibly unstable or slow)\n');
    end

    % Plot step response
    subplot(2, 2, i);
    step(T_PI);
    title(sprintf('Kp=%.2f, Ki=%.2f', Kp_test, Ki_test), 'FontSize', 11, 'FontWeight', 'bold');
    grid on;
end

% Add baseline comparison
figure('Name', 'Step Response Comparison', 'Position', [250, 250, 1000, 700]);
hold on;

% Get time vector for plotting
[y_baseline, t_baseline] = step(T_baseline);
plot(t_baseline, y_baseline, 'b-', 'LineWidth', 2.5);

legend_entries = {'Baseline (No Controller)'};

for i = 1:size(test_points, 1)
    Kp_test = test_points(i, 1);
    Ki_test = test_points(i, 2);

    if (Kp_test > -1) && (Ki_test > 0) && (Ki_test < 6.6172e3*(1+Kp_test))
        C_PI = tf([Kp_test, Ki_test], [1, 0]);
        T_PI = feedback(C_PI * H, 1);
        [y_PI, t_PI] = step(T_PI);
        plot(t_PI, y_PI, 'LineWidth', 1.5);
        legend_entries{end+1} = sprintf('PI: Kp=%.2f, Ki=%.0f', Kp_test, Ki_test);
    end
end

title('Step Response Comparison: Baseline vs PI Controllers', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Time (s)', 'FontSize', 11);
ylabel('Amplitude', 'FontSize', 11);
legend(legend_entries, 'Location', 'best', 'FontSize', 10);
grid on;
hold off;

%% ========================================================================
%  Part 6: Bandwidth Analysis and Optimization
%% ========================================================================
fprintf('\n========================================\n');
fprintf('BANDWIDTH ANALYSIS AND OPTIMIZATION\n');
fprintf('========================================\n');

% Calculate baseline bandwidth
[mag_baseline, ~, w_baseline] = bode(T_baseline, logspace(-1, 6, 10000));
mag_baseline = squeeze(mag_baseline);
w_baseline = squeeze(w_baseline);

% Find DC gain (low frequency gain)
DC_gain_baseline = mag_baseline(1);

% Find -3dB point (0.707 * DC_gain in linear scale)
BW_threshold_baseline = 0.707 * DC_gain_baseline;
idx_bw_baseline = find(mag_baseline <= BW_threshold_baseline, 1, 'first');
if ~isempty(idx_bw_baseline)
    BW_baseline = w_baseline(idx_bw_baseline);
else
    BW_baseline = NaN;
end

% Convert to Hz
BW_baseline_Hz = BW_baseline / (2*pi);

fprintf('\nBaseline System (Unity Feedback):\n');
fprintf('  DC Gain: %.4f (%.4f dB)\n', DC_gain_baseline, 20*log10(DC_gain_baseline));
fprintf('  Bandwidth (-3dB point): %.2f Hz\n', BW_baseline_Hz);

% Create grid for bandwidth contour plot
Ki_grid = linspace(100, 35000, 100);
Kp_grid = linspace(0, 4.5, 100);
[Ki_mesh, Kp_mesh] = meshgrid(Ki_grid, Kp_grid);

BW_mesh = zeros(size(Ki_mesh));  % Will store in rad/s, convert to Hz later

fprintf('\nComputing bandwidth for Kp-Ki grid...\n');
fprintf('This may take a few moments...\n');

for i = 1:numel(Ki_mesh)
    Kp_val = Kp_mesh(i);
    Ki_val = Ki_mesh(i);

    % Check stability
    if (Kp_val > -1) && (Ki_val > 0) && (Ki_val < 6.6172e3*(1+Kp_val))
        try
            % Create PI controller
            C_temp = tf([Kp_val, Ki_val], [1, 0]);
            T_temp = feedback(C_temp * H, 1);

            % Check if system is stable by checking poles
            if all(real(pole(T_temp)) < 0)
                % Calculate bandwidth
                [mag_temp, ~, w_temp] = bode(T_temp, logspace(-1, 6, 5000));
                mag_temp = squeeze(mag_temp);
                w_temp = squeeze(w_temp);

                % Find DC gain and -3dB point
                DC_gain_temp = mag_temp(1);
                BW_threshold_temp = 0.707 * DC_gain_temp;

                idx_bw = find(mag_temp <= BW_threshold_temp, 1, 'first');
                if ~isempty(idx_bw)
                    BW_mesh(i) = w_temp(idx_bw);
                else
                    BW_mesh(i) = NaN;
                end
            else
                BW_mesh(i) = NaN;
            end
        catch
            BW_mesh(i) = NaN;
        end
    else
        BW_mesh(i) = NaN;
    end
end

fprintf('Bandwidth computation complete!\n');

% Convert bandwidth mesh to Hz
BW_mesh_Hz = BW_mesh / (2*pi);

% Find maximum bandwidth
[max_BW_Hz, max_idx] = max(BW_mesh_Hz(:));
Kp_opt = Kp_mesh(max_idx);
Ki_opt = Ki_mesh(max_idx);

fprintf('\n=== OPTIMAL PI CONTROLLER FOR MAXIMUM BANDWIDTH ===\n');
fprintf('Kp_optimal = %.4f\n', Kp_opt);
fprintf('Ki_optimal = %.4f\n', Ki_opt);
fprintf('Maximum Bandwidth = %.2f Hz\n', max_BW_Hz);
fprintf('Bandwidth Improvement = %.2f%%\n', (max_BW_Hz/BW_baseline_Hz - 1)*100);

% Plot bandwidth contour
figure('Name', 'Bandwidth Contour Map', 'Position', [300, 300, 1000, 800]);
hold on;

% Plot contour (using Hz)
contourf(Ki_mesh, Kp_mesh, BW_mesh_Hz, 20, 'LineWidth', 1);
colorbar;
colormap(jet);

% Overlay stability boundaries
plot(Ki_upper(valid_idx), Kp_range(valid_idx), 'r-', 'LineWidth', 2.5, 'DisplayName', 'Stability Boundary');
plot(Ki_lower(valid_idx), Kp_range(valid_idx), 'k-', 'LineWidth', 2, 'DisplayName', 'Ki = 0');

% Mark optimal point
plot(Ki_opt, Kp_opt, 'r*', 'MarkerSize', 20, 'LineWidth', 3, 'DisplayName', ...
    sprintf('Optimal (Kp=%.2f, Ki=%.0f)', Kp_opt, Ki_opt));

% Mark baseline bandwidth level
text(Ki_opt + 2000, Kp_opt + 0.3, sprintf('Max BW: %.1f Hz', max_BW_Hz), ...
    'FontSize', 11, 'FontWeight', 'bold', 'Color', 'r', 'BackgroundColor', 'w');

xlabel('Ki (Integral Gain)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Kp (Proportional Gain)', 'FontSize', 12, 'FontWeight', 'bold');
title('Bandwidth Contour Map (Hz)', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'northwest', 'FontSize', 10);
grid on;
xlim([0, 40000]);
ylim([0, 5]);
hold off;

%% Test optimal controller
fprintf('\n=== TESTING OPTIMAL BANDWIDTH CONTROLLER ===\n');

C_opt = tf([Kp_opt, Ki_opt], [1, 0]);
T_opt = feedback(C_opt * H, 1);

% Performance metrics
poles_opt = pole(T_opt);
fprintf('Closed-loop poles:\n');
disp(poles_opt);

try
    step_info_opt = stepinfo(T_opt);
    fprintf('\nStep Response Characteristics:\n');
    fprintf('  Rise Time: %.6f s\n', step_info_opt.RiseTime);
    fprintf('  Settling Time: %.6f s\n', step_info_opt.SettlingTime);
    fprintf('  Overshoot: %.4f %%\n', step_info_opt.Overshoot);
    fprintf('  Peak: %.4f\n', step_info_opt.Peak);
catch
    fprintf('Could not compute step info\n');
end

[Gm_opt, Pm_opt, Wgm_opt, Wpm_opt] = margin(T_opt);
fprintf('\nFrequency Domain Characteristics:\n');
fprintf('  Gain Margin: %.4f dB (at %.2f Hz)\n', 20*log10(Gm_opt), Wgm_opt/(2*pi));
fprintf('  Phase Margin: %.4f deg (at %.2f Hz)\n', Pm_opt, Wpm_opt/(2*pi));
fprintf('  Bandwidth: %.2f Hz\n', max_BW_Hz);

% Comparison plot: Baseline vs Optimal
figure('Name', 'Optimal Bandwidth PI Controller', 'Position', [350, 350, 1400, 900]);

subplot(2,3,1);
[y_opt, t_opt] = step(T_opt);
plot(t_baseline, y_baseline, 'b-', 'LineWidth', 2);
hold on;
plot(t_opt, y_opt, 'r-', 'LineWidth', 2);
title('Step Response Comparison');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Baseline', sprintf('Optimal BW (Kp=%.2f, Ki=%.0f)', Kp_opt, Ki_opt));
grid on;
hold off;

subplot(2,3,2);
bode(T_baseline, T_opt);
title('Bode Diagram Comparison');
legend('Baseline', 'Optimal BW');
grid on;

subplot(2,3,3);
nyquist(T_baseline, T_opt);
title('Nyquist Diagram Comparison');
legend('Baseline', 'Optimal BW');
grid on;

subplot(2,3,4);
pzmap(T_baseline, 'b', T_opt, 'r');
title('Pole-Zero Map Comparison');
legend('Baseline', 'Optimal BW');
grid on;

subplot(2,3,5);
impulse(T_baseline, T_opt);
title('Impulse Response Comparison');
legend('Baseline', 'Optimal BW');
grid on;

subplot(2,3,6);
% Frequency response magnitude comparison
[mag_opt, ~, w_opt] = bode(T_opt, logspace(-1, 6, 5000));
mag_opt = squeeze(mag_opt);
w_opt = squeeze(w_opt);

% Convert frequency to Hz for plotting
w_baseline_Hz = w_baseline / (2*pi);
w_opt_Hz = w_opt / (2*pi);

semilogx(w_baseline_Hz, 20*log10(mag_baseline), 'b-', 'LineWidth', 2);
hold on;
semilogx(w_opt_Hz, 20*log10(mag_opt), 'r-', 'LineWidth', 2);
yline(-3, 'k--', 'LineWidth', 1.5);
xline(BW_baseline_Hz, 'b--', 'LineWidth', 1.5);
xline(max_BW_Hz, 'r--', 'LineWidth', 1.5);
title('Magnitude Response (Bandwidth Comparison)');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
legend('Baseline', 'Optimal BW', '-3dB Line', ...
    sprintf('BW_{baseline}=%.1f Hz', BW_baseline_Hz), ...
    sprintf('BW_{optimal}=%.1f Hz', max_BW_Hz), 'Location', 'southwest');
grid on;
xlim([1e0, 1e5]);
hold off;

fprintf('\n========================================\n');
fprintf('ANALYSIS COMPLETE!\n');
fprintf('========================================\n');
fprintf('All plots have been generated.\n');
fprintf('Please review the figures for detailed analysis.\n\n');
fprintf('KEY FINDINGS:\n');
fprintf('├─ Baseline Bandwidth: %.2f Hz\n', BW_baseline_Hz);
fprintf('├─ Optimal Bandwidth: %.2f Hz\n', max_BW_Hz);
fprintf('├─ Improvement: %.2f%%\n', (max_BW_Hz/BW_baseline_Hz - 1)*100);
fprintf('└─ Optimal PI Gains: Kp = %.4f, Ki = %.4f\n', Kp_opt, Ki_opt);
