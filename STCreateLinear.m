function [cstTrain] = STCreateLinear(fStartFreq, fEndFreq)

% STCreateLinear - FUNCTION Create a linearly changing frequency spike train definition
% $Id: STCreateLinear.m 8352 2008-02-04 17:53:02Z dylan $
%
% Usage: [stTrain] = STCreateLinear(fStartFreq, fEndFreq)
%        [cstTrain] = STCreateLinear(vfStartFreq, vfEndFreq)
%
% STCreateLinear will create a spike train definition where the spiking
% frequency increases linearly with time.  'fStartFreq' and 'fEndFreq' specify
% the start and ending frequencies respectively.  Note that the duration of a
% spike train (and thus the rate of chance of frequency) is specified when the
% train is instantiated with STInstantiate.  'stTrain' will comprise of a
% field 'definition' containing the spike train definition.
%
% Either (or both) of 'vfStartFreq' and 'vfEndFreq' can optionally be
% provided as arrays.  In this case, 'cstTrain' will be a cell array of
% spike trains, with the arguments for each definition taken element-wise
% from the input array arguments.  In the case when only a single argument
% is an array, that scalar value will be used to create the definition for
% all values of the array argument.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 2)
    disp ('*** STCreateLinear: Incorrect number of arguments');
    help STCreateLinear;
    return;
end


% -- Check number of elements for input arguments

% - Determine argument number of elements
nStartElems = numel(fStartFreq);
nEndElems = numel(fEndFreq);
vArgElems = [nStartElems nEndElems];
nNumTrains = max(vArgElems);

% - Boolean tests for argument sizes
bArrayOutput = any(vArgElems > 1);
bArrayStart = (nStartElems > 1);
bArrayEnd = (nEndElems > 1);

% - Should we make a cellular output?
if (bArrayOutput)
    % - Is the start frequency not yet an array?
    if (~bArrayStart)
        % - Use the same start frequenxy for all trains
        nNumTrains = nEndElems;
        fStartFreq = repmat(fStartFreq, nNumTrains, 1);
    
    % - Is the end frequency not yet an array?
    elseif (~bArrayEnd)
        % - Use the same end frequency for all trains
        nNumTrains = nStartElems;
        fEndFreq = repmat(fEndFreq, nNumTrains, 1);
        
    % - Check that all arguments have the same number of elements
    elseif (nStartElems ~= nEndElems)
        disp('*** STCreateLinear: When arguments are supplied as arrays, the same number');
        disp('       of elements must be in each.');
        return;
    end
end


% -- Create definitions

cstTrain = cell(nNumTrains, 1);

for (nTrainIndex = 1:nNumTrains)
    cstTrain{nTrainIndex}.definition.strType = 'linear';
    cstTrain{nTrainIndex}.definition.fStartFreq = fStartFreq(nTrainIndex);
    cstTrain{nTrainIndex}.definition.fEndFreq = fEndFreq(nTrainIndex);
    cstTrain{nTrainIndex}.definition.fMaxFreq = max([fStartFreq(nTrainIndex) fEndFreq(nTrainIndex)]);
    cstTrain{nTrainIndex}.definition.fhInstFreq = @STInstantaneousFrequencyLinear;
    cstTrain{nTrainIndex}.definition.fhPlotFunction = @STPlotDefLinear;
end

% - Fix output variable for only a single spike train
if (nNumTrains == 1)
    cstTrain = cstTrain{1};
end

% --- END of STCreateLinear.m ---
