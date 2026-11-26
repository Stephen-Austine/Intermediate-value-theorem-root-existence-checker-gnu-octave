function roots_found = find_roots_by_scanning(f, a, b, n, tol)
% FIND_ROOTS_BY_SCANNING  All sign-change roots of f in [a, b] (scan, then bisect).
%
%   r = find_roots_by_scanning(f, a, b)
%   r = find_roots_by_scanning(f, a, b, n, tol)
%
%   Combines find_sign_change_brackets() (which uses the IVT to confirm a
%   root is trapped) with ivt_find_c() (which pins it down).
%
%   EXAMPLE
%     f = @(x) x.^5 - 2*x.^3 + 3*x.^2 - 1;
%     find_roots_by_scanning(f, -2, 1)'
%
%   See also: find_sign_change_brackets, ivt_find_c

  if nargin < 3
    print_usage();
  end
  if nargin < 4, n = []; end
  if nargin < 5 || isempty(tol), tol = 1e-12; end
  br = find_sign_change_brackets(f, a, b, n);
  roots_found = zeros(rows(br), 1);
  for i = 1:rows(br)
    if br(i, 1) == br(i, 2)
      roots_found(i) = br(i, 1);
    else
      roots_found(i) = ivt_find_c(f, br(i, 1), br(i, 2), 0, tol);
    end
  end
end

%!test
%! f = @(x) x.^5 - 2*x.^3 + 3*x.^2 - 1;
%! r = find_roots_by_scanning(f, -2, 1);
%! assert(numel(r), 3);
%! assert(f(r), zeros(3, 1), 1e-9);

%!assert(find_roots_by_scanning(@(x) cos(x), 0, 3), pi/2, 1e-10)
