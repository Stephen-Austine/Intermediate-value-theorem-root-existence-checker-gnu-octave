function result = ivt_check(f, a, b, k)
% IVT_CHECK  Check the hypotheses of the Intermediate Value Theorem on [a, b].
%
%   result = ivt_check(f, a, b)        % is there a root?   (k = 0)
%   result = ivt_check(f, a, b, k)     % is the value k attained?
%
%   Intermediate Value Theorem: if f is continuous on [a, b] and k lies
%   between f(a) and f(b), then f(c) = k for at least one c in [a, b].
%
%   A computer cannot PROVE continuity, so this function does what it can:
%     * evaluates f(a) and f(b) and tests whether k lies between them;
%     * samples f on 2001 points and warns about NaN/Inf values and about
%       suspicious jumps (a jump more than 100x the typical step), which is
%       how poles and jump discontinuities show up.
%
%   OUTPUT  result   struct with fields
%       fa, fb, k            the three numbers involved
%       k_between            true if min(f(a),f(b)) <= k <= max(f(a),f(b))
%       suspicious           true if the sampling found NaN/Inf or a big jump
%       suspicious_at        x location of the largest jump (NaN if none)
%       guaranteed           true if k_between and not suspicious
%       message              one-sentence conclusion
%
%   EXAMPLE
%     f = @(x) x.^5 - 2*x.^3 + 3*x.^2 - 1;
%     r = ivt_check(f, 0, 1);      % f(0) = -1, f(1) = 1  ->  a root exists
%     disp(r.message)
%
%   See also: ivt_find_c, find_sign_change_brackets

  if nargin < 3
    print_usage();
  end
  if nargin < 4 || isempty(k)
    k = 0;
  end
  if ! (isscalar(a) && isscalar(b) && a < b && isfinite(a) && isfinite(b))
    error("ivt_check:badInterval", "Need finite a < b.");
  end

  fa = f(a);
  fb = f(b);
  k_between = (min(fa, fb) <= k) && (k <= max(fa, fb));

  % --- heuristic continuity screen ---------------------------------------
  x = linspace(a, b, 2001);
  y = f(x);
  suspicious = false;
  suspicious_at = NaN;
  if any(! isfinite(y))
    suspicious = true;
    suspicious_at = x(find(! isfinite(y), 1));
  else
    d = abs(diff(y));
    typical = median(d);
    [dmax, imax] = max(d);
    if dmax > 100 * max(typical, eps) && dmax > 1e-3 * max(1, max(abs(y)))
      suspicious = true;
      suspicious_at = (x(imax) + x(imax + 1)) / 2;
    end
  end

  guaranteed = k_between && ! suspicious;
  if ! k_between
    msg = sprintf("k = %g is not between f(a) = %g and f(b) = %g: the theorem says nothing.", k, fa, fb);
  elseif suspicious
    msg = sprintf("k is between f(a) and f(b), BUT f looks discontinuous near x = %.6g: the theorem may not apply.", suspicious_at);
  else
    msg = sprintf("f(a) = %g and f(b) = %g bracket k = %g: some c in [%g, %g] has f(c) = %g.", fa, fb, k, a, b, k);
  end

  result = struct("fa", fa, "fb", fb, "k", k, "k_between", k_between, ...
                  "suspicious", suspicious, "suspicious_at", suspicious_at, ...
                  "guaranteed", guaranteed, "message", msg);
end

%!test
%! r = ivt_check(@(x) x.^5 - 2*x.^3 + 3*x.^2 - 1, 0, 1);
%! assert(r.fa, -1);
%! assert(r.fb, 1);
%! assert(r.guaranteed);

%!test
%! r = ivt_check(@(x) x.^2 + 1, -1, 1);
%! assert(! r.k_between);

%!test
%! r = ivt_check(@(x) tan(x), 1, 2);
%! assert(r.k_between);
%! assert(r.suspicious);
%! assert(! r.guaranteed);
