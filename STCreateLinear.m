function [stTrain] = STCreateLinear(fStartFreq, fEndFreq)

% FUNCTION STCreateLinear - Create a linearly changing frequency spike train definition
%
% Usage: [stTrain] = STCreateLinear(fStartFreq, fEndFreq)
%
% STCreateLinear will create a spike train definition where the spiking
% frequency increases linearly with time.  'fStartFreq' and 'fEndFreq' specify
% the start and ending frequencies respectively.  Note that the duration of a
% spike train (and thus the rate of chance of frequency) is specified when the
% train is instantiated with STInstantiate.  'stTrain' will comprise of a
% field 'definition' containing the spike train definition.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% $Id: STCreateLinear.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Check arguments

if (nargin < 1)
    disp ('*** STCreateLinear: Incorrect number of arguments');
    help STCreateLinear;
    return;
end

% -- Create definition

stTrain = [];
stTrain.definition.strType = 'linear';
stTrain.definition.fStartFreq = fStartFreq;
stTrain.definition.fEndFreq = fEndFreq;
stTrain.definition.fhInstFreq = @STInstantaneousFrequencyLinear;

% --- END of STCreateLinear.m ---

% $Log: STCreateLinear.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/04 09:40:06  dylan
% Added ID tags and logs to all version managed files
%