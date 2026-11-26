% RUN_TESTS  Self-checking test-suite for the Intermediate Value Theorem project.
%
%   Run from the project root:
%       octave --no-gui tests/run_tests.m
%
%   Exits with status 1 if anything fails, so it works in CI.

1;

function run_case(name, fn)
  global n_fail n_pass
  try
    fn();
    n_pass += 1;
    printf("  PASS  %s\n", name);
  catch err
    n_fail += 1;
    printf("  FAIL  %s\n        %s\n", name, err.message);
  end
end

function check_all_values_attained()
  f = @(x) x.^5 - 2*x.^3 + 3*x.^2 - 1;
  for k = linspace(-1, 1, 21)
    c = ivt_find_c(f, 0, 1, k);
    assert(c >= 0 && c <= 1);
    assert(f(c), k, 1e-8);
  end
end

function check_scan_matches_roots()
  f = @(x) x.^5 - 2*x.^3 + 3*x.^2 - 1;
  r = sort(find_roots_by_scanning(f, -2, 1));
  pr = roots([1 0 -2 3 0 -1]);
  pr = sort(real(pr(abs(imag(pr)) < 1e-9)));
  assert(r, pr, 1e-9);
end

function check_error(fn, id)
  try
    fn();
  catch err
    assert(err.identifier, id);
    return;
  end
  error("expected error %s", id);
end

function check_degenerate_bracket()
  br = find_sign_change_brackets(@(x) x, -1, 1, 4);     % grid hits x = 0 exactly
  assert(rows(br), 1);
  assert(br, [0 0]);
end

function check_sinx()
  r = find_roots_by_scanning(@(x) sin(x), 1, 10, 500);
  assert(r', [pi, 2*pi, 3*pi], 1e-9);
end

global n_fail n_pass
n_fail = 0;  n_pass = 0;

here = fileparts(mfilename("fullpath"));
addpath(fullfile(here, "..", "src"));
f = @(x) x.^5 - 2*x.^3 + 3*x.^2 - 1;

printf("\nIntermediate Value Theorem project tests\n========================================\n");
run_case("f(0) = -1 and f(1) = 1 (the course example)", @() assert([f(0) f(1)], [-1 1]));
run_case("ivt_check guarantees a root on [0, 1]",     @() assert(ivt_check(f, 0, 1).guaranteed));
run_case("root of the example is 0.7191393277",       @() assert(ivt_find_c(f, 0, 1), 0.7191393277, 1e-9));
run_case("every k in [-1, 1] is attained",            @check_all_values_attained);
run_case("k outside [f(a), f(b)] is not guaranteed",  @() assert(! ivt_check(f, 0, 1, 1.5).k_between));
run_case("k exactly at f(b) counts as between",       @() assert(ivt_check(f, 0, 1, 1).k_between));
run_case("tan(x) on [1, 2] is flagged (pole)",        @() assert(ivt_check(@(x) tan(x), 1, 2).suspicious));
run_case("1/x on [-1, 1] is flagged",                 @() assert(ivt_check(@(x) 1 ./ x, -1, 1).suspicious));
run_case("sign(x) on [-1, 1] is flagged",             @() assert(ivt_check(@(x) sign(x), -1, 1).suspicious));
run_case("smooth functions are not flagged",          @() assert(! ivt_check(@(x) sin(5*x) + x.^3, -2, 2).suspicious));
run_case("x^2 - 0.25 on [-1, 1]: no guarantee",       @() assert(! ivt_check(@(x) x.^2 - 0.25, -1, 1).guaranteed));
run_case("scan finds 3 brackets in [-2, 1]",          @() assert(rows(find_sign_change_brackets(f, -2, 1)), 3));
run_case("scan = Octave roots() on [-2, 1]",          @check_scan_matches_roots);
run_case("scan finds pi, 2pi, 3pi for sin(x)",        @check_sinx);
run_case("grid point at a root -> degenerate bracket",@check_degenerate_bracket);
run_case("no sign change -> no brackets",             @() assert(rows(find_sign_change_brackets(@(x) x.^2 + 1, -3, 3)), 0));
run_case("error id: k not bracketed",                 @() check_error(@() ivt_find_c(f, 0, 1, 5), "ivt_find_c:notBracketed"));
run_case("error id: bad interval (ivt_check)",        @() check_error(@() ivt_check(f, 1, 0), "ivt_check:badInterval"));
run_case("cos(x) = x via the IVT",                    @() assert(ivt_find_c(@(x) cos(x) - x, 0, 1), 0.7390851332151607, 1e-9));

for name = {"ivt_check", "ivt_find_c", "find_sign_change_brackets", "find_roots_by_scanning"}
  [n, nmax] = test(name{1}, "quiet");
  run_case(sprintf("built-in tests of %s.m (%d/%d)", name{1}, n, nmax), @() assert(n, nmax));
end

printf("\n%d passed, %d failed\n\n", n_pass, n_fail);
if n_fail > 0
  exit(1);
end
