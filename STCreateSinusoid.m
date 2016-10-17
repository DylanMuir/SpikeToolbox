function [cstTrain] = STCreateSinusoid(fMinFreq, fMaxFreq, tPeriod)

% STCreateSinusoid - FUNCTION Create a sinusoidally changing frequency spike train definition
% $Id: STCreateSinusoid.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [stTrain] = STCreateSinusoid(fMinFreq, fMaxFreq, tPeriod)
%        [cstTrain] = STCreateSinusoid(vfMinFreq, vfMaxFreq, vtPeriod)
%
% STSinuoid will create a spike train definition, in which the spiking
% frequency changes sinusoidally with time.  'fMinFreq' and 'fMaxFreq'
% specify the minimum and maximum frequencies to use in the spike train.
% 'tPeriod' specifies the period of the frequency profile sinusoid.  'stTrain'
% will comprise of a field 'definition' containing the spike train definition.
%
% One or more of the input arguments may optionally be supplied as an
% array.  In this case, 'cstTrain' will be a cell array of spike trains,
% with the parameters for each taken element-wise from the input array
% arguments.  Any scalar arguments will be duplicated for all elements in
% the cell array of spike train definitions.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 3)
    disp ('*** STCreateSinusoid: Incorrect number of arguments');
    help STCreateSinusoid;
    return;
end


% -- Check array sizes for input arguments

% - Get array argument sizes
nMinFreqElems = numel(fMinFreq);
nMaxFreqElems = numel(fMaxFreq);
nPeriodElems = numel(tPeriod);
vArgSizes = [nMinFreqElems  nMaxFreqElems  nPeriodElems];
nNumTrains = max(vArgSizes);

% - Boolean tests for argument sizes
bArrayOutput = any(vArgSizes > 1);
bArrayMinFreq = (nMinFreqElems > 1);
bArrayMaxFreq = (nMaxFreqElems > 1);
bArrayPeriod = (nPeriodElems > 1);

% - Should we make a cellular output?
if (bArrayOutput)
    % - Is 'fMinFreq' not yet an array?
    if (~bArrayMinFreq)
        fMinFreq = repmat(fMinFreq, nNumTrains, 1);
        nMinFreqElems = nNumTrains;
    end

    % - Is 'fMaxFreq' not yet an array?
    if (~bArrayMaxFreq)
        fMaxFreq = repmat(fMaxFreq, nNumTrains, 1);
        nMaxFreqElems = nNumTrains;
    end
    
    % - Is 'tPeriod' not yet an array?
    if (~bArrayPeriod)
        tPeriod = repmat(tPeriod, nNumTrains, 1);
        nPeriodElems = nNumTrains;
    end
    
    % - Check that all arguments are the same size
    vArgSizes = [nMinFreqElems  nMaxFreqElems  nPeriodElems];
    
    if (any(vArgSizes ~= nNumTrains))
        disp('*** STCreateSinusoid: When arguments are supplied as arrays, all array');
        disp('       arguments must have the same number of elements.');
        return;
    end
end


% -- Create definition

cstTrain = cell(nNumTrains, 1);

for (nTrainIndex = 1:nNumTrains)
    cstTrain{nTrainIndex}.definition.strType = 'sinusoid';
    
    % - Ensure minimum and maximum frequencies are properly ordered
    [fFreqs] = sort([fMinFreq(nTrainIndex) fMaxFreq(nTrainIndex)]);

    cstTrain{nTrainIndex}.definition.fMinFreq = fFreqs(1);
    cstTrain{nTrainIndex}.definition.fMaxFreq = fFreqs(2);
    cstTrain{nTrainIndex}.definition.tPeriod = tPeriod(nNumTrains);
    cstTrain{nTrainIndex}.definition.fhInstFreq = @STInstantaneousFrequencySinusoid;
    cstTrain{nTrainIndex}.definition.fhPlotFunction = @STPlotDefSinusoid;
end

% - Fix output argument for a single spike train
if (nNumTrains == 1)
    cstTrain = cstTrain{1};
end

% --- END of STCreateSinusoid.m ---
