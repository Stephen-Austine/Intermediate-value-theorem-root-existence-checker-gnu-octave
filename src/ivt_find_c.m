function [c, info] = ivt_find_c(f, a, b, k, tol)
% IVT_FIND_C  Locate a point c in [a, b] with f(c) = k (the c promised by the IVT).
%
%   [c, info] = ivt_find_c(f, a, b)            % k = 0: find a root
%   [c, info] = ivt_find_c(f, a, b, k, tol)
%
%   Applies bisection to g(x) = f(x) - k. The theorem guarantees the point
%   exists; this function finds it to within tol (default 1e-10).
%
%   OUTPUT  c      the point
%           info   struct: iterations, residual |f(c) - k|, error_bound
%
%   EXAMPLE
%     f = @(x) x.^5 - 2*x.^3 + 3*x.^2 - 1;
%     c = ivt_find_c(f, 0, 1, 0.5)     % f(c) = 0.5
%
%   See also: ivt_check, find_sign_change_brackets

  if nargin < 3
    print_usage();
  end
  if nargin < 4 || isempty(k),   k = 0;      end
  if nargin < 5 || isempty(tol), tol = 1e-10; end
  if ! (a < b)
    error("ivt_find_c:badInterval", "Need a < b.");
  end

  g = @(x) f(x) - k;
  ga = g(a);  gb = g(b);
  if sign(ga) * sign(gb) > 0
    error("ivt_find_c:notBracketed", ...
          "k = %g is not between f(a) = %g and f(b) = %g.", k, f(a), f(b));
  end

  iterations = 0;
  if ga == 0
    c = a;
  elseif gb == 0
    c = b;
  else
    while (b - a) / 2 > tol
      iterations += 1;
      c = a + (b - a) / 2;
      gc = g(c);
      if gc == 0
        break;
      end
      if sign(ga) * sign(gc) < 0
        b = c;  gb = gc;
      else
        a = c;  ga = gc;
      end
    end
    c = a + (b - a) / 2;
  end
  info = struct("iterations", iterations, "residual", abs(f(c) - k), ...
                "error_bound", (b - a) / 2);
end

%!test
%! f = @(x) x.^5 - 2*x.^3 + 3*x.^2 - 1;
%! [c, info] = ivt_find_c(f, 0, 1, 0.5);
%! assert(f(c), 0.5, 1e-9);
%! assert(c > 0 && c < 1);

%!test
%! c = ivt_find_c(@(x) x.^2, 0, 3, 4);
%! assert(c, 2, 1e-9);

%!error <not between> ivt_find_c(@(x) x.^2, 0, 3, 10)
