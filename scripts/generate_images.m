% GENERATE_IMAGES  Re-create every plot used in README.md.
%
%   Run from the project root:
%       octave --no-gui scripts/generate_images.m

here = fileparts(mfilename("fullpath"));
root_dir = fullfile(here, "..");
addpath(fullfile(root_dir, "src"));
addpath(here);
out = fullfile(root_dir, "images");
if ! exist(out, "dir"), mkdir(out); end

BLUE = [0.11 0.35 0.75];  RED = [0.85 0.20 0.15];  GREEN = [0.10 0.60 0.35];
ORANGE = [0.95 0.55 0.10]; GREY = [0.45 0.45 0.45];

f = @(x) x.^5 - 2*x.^3 + 3*x.^2 - 1;

% ------------------------------------------------------------------ 1
fig = figure("visible", "off", "position", [100 100 1000 700]);
x = linspace(0, 1, 500);
hold on;
fill([0 1 1 0], [-1 -1 1 1], [0.93 0.95 0.99], "edgecolor", "none");
plot(x, f(x), "-", "linewidth", 3, "color", BLUE);
ks = [-0.5 0 0.5];  cols = {GREEN, RED, ORANGE};
for i = 1:3
  c = ivt_find_c(f, 0, 1, ks(i));
  plot([0 1], [ks(i) ks(i)], "--", "color", cols{i}, "linewidth", 2);
  plot([c c], [-1.2 ks(i)], ":", "color", cols{i}, "linewidth", 2);
  plot(c, ks(i), "o", "markersize", 12, "markerfacecolor", cols{i}, "markeredgecolor", cols{i});
  text(c + 0.015, -1.1, sprintf("c = %.4f", c), "fontsize", 12, "color", cols{i});
  text(0.02, ks(i) + 0.07, sprintf("k = %.1f", ks(i)), "fontsize", 12, "color", cols{i});
end
plot(0, f(0), "s", "markersize", 11, "markerfacecolor", BLUE, "markeredgecolor", BLUE);
plot(1, f(1), "s", "markersize", 11, "markerfacecolor", BLUE, "markeredgecolor", BLUE);
text(0.035, -1.09, "f(0) = -1", "fontsize", 12, "horizontalalignment", "left", "color", BLUE);
text(0.80, 1.07, "f(1) = 1", "fontsize", 12, "color", BLUE);
grid on; axis([0 1 -1.2 1.25]); xlabel("x"); ylabel("f(x)");
title("IVT: every level k between f(0) = -1 and f(1) = 1 is reached at some c in [0, 1]");
save_figure(fig, fullfile(out, "ivt-every-level-is-attained.png"));

% ------------------------------------------------------------------ 2
fig = figure("visible", "off", "position", [100 100 1100 640]);
xx = linspace(-2, 1, 600);
br = find_sign_change_brackets(f, -2, 1, 300);
rts = find_roots_by_scanning(f, -2, 1);
hold on;
for i = 1:rows(br)
  fill([br(i, 1) br(i, 2) br(i, 2) br(i, 1)] + [-0.03 0.03 0.03 -0.03], [-5 -5 5 5], [1.0 0.9 0.7], "edgecolor", "none");
end
plot(xx, f(xx), "-", "linewidth", 3, "color", BLUE);
plot([-2 1], [0 0], "-", "color", GREY, "linewidth", 1);
xs = linspace(-2, 1, 31);  ys = f(xs);
plot(xs(ys > 0), ys(ys > 0), "o", "markersize", 6, "markerfacecolor", GREEN, "markeredgecolor", GREEN);
plot(xs(ys < 0), ys(ys < 0), "o", "markersize", 6, "markerfacecolor", RED, "markeredgecolor", RED);
plot(rts, zeros(size(rts)), "d", "markersize", 12, "markerfacecolor", "k", "markeredgecolor", "k");
for i = 1:numel(rts)
  text(rts(i) + 0.05, 1.6, sprintf("x = %.4f", rts(i)), "fontsize", 12, "rotation", 90);
end
grid on; axis([-2 1 -4 3]); xlabel("x"); ylabel("f(x)");
title("Scanning [-2, 1]: each sign change (orange band) traps a root (black diamond)");
text(-1.95, -3.2, "green dots: f > 0     red dots: f < 0     black diamonds: roots", "fontsize", 12);
text(-1.95, -3.65, "orange bands: sub-intervals where the sign changes", "fontsize", 12, "color", [0.75 0.4 0]);
save_figure(fig, fullfile(out, "ivt-sign-change-scan.png"));

% ------------------------------------------------------------------ 3
fig = figure("visible", "off", "position", [100 100 1200 900]);
subplot(2, 2, 1);
x = linspace(1, 2, 3000);  y = tan(x);  y(abs(y) > 10) = NaN;
plot(x, y, "-", "linewidth", 3, "color", BLUE); hold on;
plot([1 2], [0 0], "-", "color", GREY); plot([pi/2 pi/2], [-10 10], "--", "color", RED, "linewidth", 2);
axis([1 2 -10 10]); grid on; title("tan(x) on [1, 2]: sign change at a pole, no root");
subplot(2, 2, 2);
x = linspace(-1, 1, 3001);  y = 1 ./ x;  y(abs(y) > 10) = NaN;
plot(x(x < 0), y(x < 0), "-", "linewidth", 3, "color", BLUE); hold on;
plot(x(x > 0), y(x > 0), "-", "linewidth", 3, "color", BLUE);
plot([-1 1], [0 0], "-", "color", GREY);
axis([-1 1 -10 10]); grid on; title("1/x on [-1, 1]: not continuous at 0");
subplot(2, 2, 3);
plot([-1 0], [-1 -1], "-", "linewidth", 3, "color", BLUE); hold on;
plot([0 1], [1 1], "-", "linewidth", 3, "color", BLUE);
plot(0, -1, "o", "markersize", 9, "markerfacecolor", "w", "markeredgecolor", BLUE);
plot(0, 1, "o", "markersize", 9, "markerfacecolor", BLUE, "markeredgecolor", BLUE);
plot([-1 1], [0 0], "-", "color", GREY); plot([-1 1], [0.4 0.4], "--", "color", RED, "linewidth", 2);
text(-0.95, 0.5, "k = 0.4 is never attained", "color", RED, "fontsize", 12);
axis([-1 1 -1.5 1.5]); grid on; title("step function: jumps over every value between -1 and 1");
subplot(2, 2, 4);
x = linspace(-1, 1, 400);
plot(x, x.^2 - 0.25, "-", "linewidth", 3, "color", BLUE); hold on;
plot([-1 1], [0 0], "-", "color", GREY);
plot([-0.5 0.5], [0 0], "o", "markersize", 11, "markerfacecolor", RED, "markeredgecolor", RED);
grid on; title("x^2 - 0.25: f(-1) = f(1) > 0, yet two roots exist");
save_figure(fig, fullfile(out, "ivt-when-it-does-not-apply.png"));

% ------------------------------------------------------------------ 4
fig = figure("visible", "off", "position", [100 100 1000 600]);
ks = linspace(-1, 1, 81);
cs = arrayfun(@(k) ivt_find_c(f, 0, 1, k), ks);
plot(cs, ks, "-", "linewidth", 3, "color", BLUE); hold on;
plot(cs(41), ks(41), "o", "markersize", 12, "markerfacecolor", RED, "markeredgecolor", RED);
text(cs(41) + 0.02, -0.15, "root: c = 0.7191", "fontsize", 12, "color", RED);
grid on; xlabel("c  (point located by bisection)"); ylabel("level k");
title("ivt_find_c turns the existence statement into numbers: one c for each k in [-1, 1]", "interpreter", "none");
save_figure(fig, fullfile(out, "ivt-find-c-for-every-level.png"));

printf("Images written to %s\n", out);
