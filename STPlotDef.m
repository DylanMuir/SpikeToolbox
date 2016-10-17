function [hFigure] = STPlotDef(stTrain)

% STPlotDef - FUNCTION [Internal] Make a plot of a spike train definition
% $Id: STPlotDef.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: <[hFigure]> = STPlotDef(stTrain)
%
% 'stTrain' is a spike train with a definition.  STPlotDef will make a
% descriptive plot of the spike train definition, showing the important
% features.
%
% The optional return argument 'hFigure' will return the handle of the new
% figure created.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 28th February, 2005
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 1)
   disp('*** STPlotDef: Incorrect usage');
   help STPlotDef;
   return;
end

% - Check for a spike train definition
if (~FieldExists(stTrain, 'definition'))
   disp('*** STPlotDef: ''stTrain'' must contain a spike train definition');
   return;
end

% - We should keep the figure handle if the user has requested it
bKeepHandle = (nargout > 0);

% - Make the figure using the plot function specified by the definition
hFigure = feval(stTrain.definition.fhPlotFunction, stTrain.definition);

% - Clear the figure handle, if the user doesn't want it
if (~bKeepHandle)
   clear hFigure;
end

% --- END of STPlotDef.m ---
