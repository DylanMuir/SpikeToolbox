function [stTrain] = STCreateSinusoid(fMinFreq, fMaxFreq, tPeriod)

% FUNCTION STCreateSinusoid - Create a sinusoidally changing frequency spike train definition
%
% Usage: [stTrain] = STCreateSinusoid(fMinFreq, fMaxFreq, tPeriod)
%
% STSinuoid will create a spike train definition, in which the spiking
% frequency changes sinusoidally with time.  'fMinFreq' and 'fMaxFreq'
% specify the minimum and maximum frequencies to use in the spike train.
% 'tPeriod' specifies the period of the frequency profile sinusoid.  'stTrain'
% will comprise of a field 'definition' containing the spike train definition.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% $Id: STCreateSinusoid.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Check arguments

if (nargin < 1)
    disp ('*** STCreateSinusoid: Incorrect number of arguments');
    help STCreateSinusoid;
    return;
end

% -- Create definition

stTrain = [];
stTrain.definition.strType = 'sinusoid';

[fFreqs] = sort([fMinFreq fMaxFreq]);

stTrain.definition.fMinFreq = fFreqs(1);
stTrain.definition.fMaxFreq = fFreqs(2);
stTrain.definition.tPeriod = tPeriod;
stTrain.definition.fhInstFreq = @STInstantaneousFrequencySinusoid;

% --- END of STCreateSinusoid.m ---

% $Log: STCreateSinusoid.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/04 09:40:06  dylan
% Added ID tags and logs to all version managed files
%