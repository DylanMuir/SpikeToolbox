function [cstTrain] = STCreateGamma(fMeanISI, fVarISI)

% STCreateGamma - FUNCTION Define a spike train using a gamma function for the ISI distribution
% $Id: STCreateGamma.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [stTrain] = STCreateGamma(fMeanISI, fVarISI)
%        [cstTrain] = STCreateGamma(vfMeanISI, vfVarISI)
%
% STCreateGamma will create a spike train definition, in which the inter-spike
% intervals are drawn from a gamma distribution.  'fMeanFreq' and 'fVarFreq'
% define the mean firing rate and the variance of the rate respectively.
% 'stTrain' will comprise of a field 'definition' containing the spike train
% definition.
%
% Either (or both) of 'vfMeanISI' or 'vfVarISI' may optionally be supplied
% as arrays.  In this case, 'cstTrain' will be a cell array of spike
% trains, the parameters for each definition taken element-wise from the
% array arguments.  If one argument is a scalar, that value will be
% duplicated for all spike train definitions.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 28th February, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 1)
    disp ('*** STCreateGamma: Incorrect number of arguments');
    help STCreateGamma;
    return;
end


% -- Check number of elements in array arguments

% - Determine array argument sizes
nMeanElems = numel(fMeanISI);
nVarElems = numel(fVarISI);
vArgElems = [nMeanElems  nVarElems];
nNumTrains = max(vArgElems);

% - Boolean tests for argument sizes
bArrayOutput = any(vArgElems > 1);
bArrayMean = (nMeanElems > 1);
bArrayVar = (nVarElems > 1);

% - Should we make a cellular output?
if (bArrayOutput)
    % - Is 'fMeanISI' not yet an array?
    if (~bArrayMean)
        fMeanISI = repmat(fMeanISI, nNumTrains, 1);
    
    % - Is 'fVarISI' not yet an array?
    elseif (~bArrayVar)
        fVarISI = repmat(fVarISI, nNumTrains, 1);
        
    % - Are both arguments the same size?
    elseif (nVarElems ~= nMeanElems)
        disp('*** STCreateGamma: When arrays are supplied for both arguments, both');
        disp('       arrays must have the same number of elements.');
        return;
    end
end


% -- Check values of alpha and beta

% - Reshape arguments for element-wise division
fVarISI = reshape(fVarISI, nNumTrains, 1);
fMeanISI = reshape(fMeanISI, nNumTrains, 1);

% - Determine alpha and beta for each train
fAlpha = fMeanISI.^2 ./ fVarISI;
% fBeta = fAlpha ./ fMeanISI;

% - Check suitability of alpha and beta
if (any(fAlpha < 1))
   disp('--- STCreateGamma: Warning: This type of spike train definition doesn''t');
   disp('       work well unless ''fVarISI'' <= ''fMeanISI''^2.  You may get no');
   disp('       spikes when you instantiate this train.');
end


% -- Create definition

cstTrain = cell(nNumTrains, 1);

for (nTrainIndex = 1:nNumTrains);
    cstTrain{nTrainIndex}.definition.strType = 'gamma';
    cstTrain{nTrainIndex}.definition.fMeanISI = fMeanISI(nTrainIndex);
    cstTrain{nTrainIndex}.definition.fVarISI = fVarISI(nTrainIndex);
    cstTrain{nTrainIndex}.definition.fhInstFreq = @STInstantaneousFrequencyGamma;
    cstTrain{nTrainIndex}.definition.fhPlotFunction = @STPlotDefGamma;
end

% - Fix output argument for a single spike train
if (nNumTrains == 1)
    cstTrain = cstTrain{1};
end

% --- END of STCreateGamma.m ---
