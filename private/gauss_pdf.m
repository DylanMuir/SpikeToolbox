function [vPDF] = gauss_pdf(x, fMean, fVar)

% gauss_pdf - FUNCTION Calculate p(x) for a gaussian PDF
%
% Usage: [vPDF] = gauss_pdf(x, fMean, fVar)
%
% 'fMean' and 'fVar' are the mean and variance of the gaussian respectively.
% 'vPDF' will have the same number of elements as 'x', and will contain p(x)
% for each element.  If mean or variance are not supplied, then p(x) ~ N(0, 1)

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 24th November, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 3)
   disp('--- gauss_pdf: Extra arguments ignored');
end

if (nargin < 3)
   fVar = 1;
end

if (nargin < 2)
   fMean = 0;
end

if (nargin < 1)
   disp('*** gauss_pdf: Incorrect usage');
   help gauss_pdf;
   return;
end


% -- Calculate gaussian PDF

vPDF = (1 / sqrt(2 * pi * fVar)) * exp(-(x - fMean).^2 / (2 * fVar));

% --- END of gaus_pdf.m ---
