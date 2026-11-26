% DEMO_IVT  The Intermediate Value Theorem in action, and where it does not apply.
%
%   Run from the project root:
%       octave --no-gui src/demo_ivt.m

here = fileparts(mfilename("fullpath"));
addpath(here);

f = @(x) x.^5 - 2*x.^3 + 3*x.^2 - 1;

printf("\n=== 1. The example from the notes: f(x) = x^5 - 2x^3 + 3x^2 - 1 on [0, 1] ===\n\n");
printf("f(0) = %g\nf(1) = %g\n\n", f(0), f(1));
r = ivt_check(f, 0, 1);
printf("%s\n", r.message);
[c, info] = ivt_find_c(f, 0, 1);
printf("root found by bisection: c = %.10f   (|f(c)| = %.2e, %d iterations)\n", c, info.residual, info.iterations);

printf("\n=== 2. Every value between f(0) = -1 and f(1) = 1 is attained ===\n\n");
printf("%8s %14s %14s\n", "k", "c", "f(c)");
for k = [-0.9, -0.5, 0, 0.5, 0.9]
  c = ivt_find_c(f, 0, 1, k);
  printf("%8.2f %14.10f %14.10f\n", k, c, f(c));
end
printf("\nk = 1.5 lies outside [-1, 1]:\n");
r = ivt_check(f, 0, 1, 1.5);
printf("  %s\n", r.message);

printf("\n=== 3. Scanning [-2, 1] for every sign change ===\n\n");
br = find_sign_change_brackets(f, -2, 1, 300);
printf("%d brackets found\n", rows(br));
rts = find_roots_by_scanning(f, -2, 1);
printf("%-20s %18s\n", "bracket", "root");
for i = 1:rows(br)
  printf("[%7.4f, %7.4f]   %18.12f\n", br(i, 1), br(i, 2), rts(i));
end
pr = roots([1 0 -2 3 0 -1]);
printf("\nOctave's roots() finds these real roots: %s\n", sprintf("%.12f ", sort(real(pr(abs(imag(pr)) < 1e-9)))));

printf("\n=== 4. Equations as root problems: cos(x) = x and e^(-x) = x ===\n\n");
c1 = ivt_find_c(@(x) cos(x) - x, 0, 1);
c2 = ivt_find_c(@(x) exp(-x) - x, 0, 1);
printf("cos(x) = x   has a solution at x = %.10f\n", c1);
printf("e^(-x) = x   has a solution at x = %.10f\n", c2);

printf("\n=== 5. When the theorem does NOT apply ===\n\n");
printf("(a) tan(x) on [1, 2]: a sign change, but a pole at pi/2\n");
r = ivt_check(@(x) tan(x), 1, 2);
printf("    %s\n", r.message);
printf("(b) 1/x on [-1, 1]: sign change, but not continuous at 0\n");
r = ivt_check(@(x) 1 ./ x, -1, 1);
printf("    %s\n", r.message);
printf("(c) x^2 - 0.25 on [-1, 1]: roots exist at +-0.5, but f(-1) and f(1) have the same sign\n");
r = ivt_check(@(x) x.^2 - 0.25, -1, 1);
printf("    %s\n", r.message);
printf("    (the IVT is an 'if', not an 'if and only if')\n");
printf("(d) sign(x) on [-1, 1]: a jump discontinuity\n");
r = ivt_check(@(x) sign(x), -1, 1);
printf("    %s\n\n", r.message);
