function [cstTrain] = STCreateConstant(fFreq)

% STCreateConstant - FUNCTION Create a constant frequency spike train definition
% $Id: STCreateConstant.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [stTrain] = STCreateConstant(fFrequency)
%        [cstTrain] = STCreateConstant(vfFreqyency)
%
% STCreateConstant will create a spike train definition where the spiking
% frequency is constant.  'fFrequency' specifies the spiking frequency.  'stTrain'
% will comprise of a field 'definition' containing the spike train definition.
%
% 'vfFrequency' can optionally be provided as an array of frequencies.  In
% this case, 'cstTrain' will be a cell array of spike trains, each one
% corresponding to a frequncy taken in order from 'vfFrequency'.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 1)
    disp ('*** STCreateConstant: Incorrect number of arguments');
    help STCreateConstant;
    return;
end


% -- Create definitions

nNumTrains = numel(fFreq);
cstTrain = cell(nNumTrains, 1);

for (nTrainIndex = 1:nNumTrains)
    cstTrain{nTrainIndex}.definition.strType = 'constant';
    cstTrain{nTrainIndex}.definition.fFreq = fFreq(nTrainIndex);
    cstTrain{nTrainIndex}.definition.fhInstFreq = @STInstantaneousFrequencyConstant;
    cstTrain{nTrainIndex}.definition.fhPlotFunction = @STPlotDefConstant;
end

% - Fix output variables for only a single spike train
if (nNumTrains == 1)
    cstTrain = cstTrain{1};
end

% --- END of STCreateConstant.m ---
