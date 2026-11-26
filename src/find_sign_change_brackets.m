function brackets = find_sign_change_brackets(f, a, b, n)
% FIND_SIGN_CHANGE_BRACKETS  Sub-intervals of [a, b] where f changes sign.
%
%   brackets = find_sign_change_brackets(f, a, b)
%   brackets = find_sign_change_brackets(f, a, b, n)
%
%   Splits [a, b] into n equal pieces (default 400), evaluates f at the n+1
%   grid points and returns every piece [x_i, x_{i+1}] with f(x_i) f(x_{i+1}) < 0.
%   By the Intermediate Value Theorem each one contains a root of f
%   (provided f is continuous there). A grid point where f is exactly zero is
%   returned as a degenerate bracket [x_i, x_i].
%
%   Roots that touch zero without crossing (like x^2 at 0) or pairs of roots
%   closer together than the grid spacing are invisible to this method.
%
%   OUTPUT  brackets   m-by-2 matrix, one [left right] row per bracket
%
%   See also: find_roots_by_scanning, ivt_find_c

  if nargin < 3
    print_usage();
  end
  if nargin < 4 || isempty(n), n = 400; end
  if ! (a < b && n >= 1 && n == fix(n))
    error("find_sign_change_brackets:badInput", "Need a < b and a whole number n >= 1.");
  end
  x = linspace(a, b, n + 1);
  y = f(x);
  brackets = zeros(0, 2);
  for i = 1:n
    if y(i) == 0
      brackets(end + 1, :) = [x(i), x(i)];
    elseif y(i) * y(i + 1) < 0 || (y(i + 1) == 0 && i == n)
      brackets(end + 1, :) = [x(i), x(i + 1)];
    end
  end
end

%!test
%! f = @(x) x.^5 - 2*x.^3 + 3*x.^2 - 1;
%! br = find_sign_change_brackets(f, -2, 1);
%! assert(rows(br), 3);

%!assert(rows(find_sign_change_brackets(@(x) x.^2 + 1, -1, 1)), 0)
%!assert(rows(find_sign_change_brackets(@(x) sin(x), 0, 10, 1000)), 4)
