function [stTrain] = STCreateConstant(fFreq)

% FUNCTION STCreateConstant - Create a constant frequency spike train definition
%
% Usage: [stTrain] = STCreateConstant(fFreq)
%
% STCreateConstant will create a spike train definition where the spiking
% frequency is constant.  'fFreq' specifies the spiking frequency.  'stTrain'
% will comprise of a field 'definition' containing the spike train definition.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% $Id: STCreateConstant.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Check arguments

if (nargin < 1)
    disp ('*** STCreateConstant: Incorrect number of arguments');
    help STCreateConstant;
    return;
end

% -- Create definition

stTrain = [];
stTrain.definition.strType = 'constant';
stTrain.definition.fFreq = fFreq;
stTrain.definition.fhInstFreq = @STInstantaneousFrequencyConstant;

% --- END of STCreateConstant.m ---

% $Log: STCreateConstant.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/04 09:40:06  dylan
% Added ID tags and logs to all version managed files
%