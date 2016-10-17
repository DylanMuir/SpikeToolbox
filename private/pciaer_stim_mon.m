function [mMonEvents] = pciaer_stim_mon(mStimEvents, fStimDuration, fMonDuration)

% pciaer_stim_mon - Stimulate and monitor using the PCI-AER system
% .M file: $Id: pciaer_stim_mon.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [mMonEvents] = pciaer_stim_mon(mStimEvents, tStimDuration <,tMonDuration>
%
% Where: 'mStimEvents' is a matrix of events to send to the PCI-AER system as
% stimulus.  Each row must have the format ['isi'  'address'], where 'isi' is
% an inter-spike interval in microseconds and 'address' is the hardware
% address the event should be sent to.  'tStimDuration' and the optional
% argument 'tMonDuration' are the durations of stimulus and monitoring,
% respectively.  If not provided, 'tMonDuration' defaults to 'tStimDuration'.
% Both times should be in seconds.
%
% 'mMonEvents' will contain the events observed from the PCI-AER monitor.
% This matrix will have the format ['timestamp'  'address'], where 'timestamp'
% is the time stamp of the event in microseconds and 'address' is the
% originating hardware address.

% NOTE: THIS IS A DUMMY FUNCTION, AND WILL ONLY BE EXECUTED IF
% pciaer_stim_mon.mex___ HAS NOT BEEN COMPILED

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th February, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Display some help

disp('*** pciaer_stim_mon: MEX function has not been compiled');
disp('    This PCI-AER low-level link function is not yet available to the');
disp('    MATLAB workspace.  To compile this function, perform these');
disp('    commands in a non-MATLAB shell:');
disp('       export PCIAER_DIR=<PCI-AER root directory>');
fprintf(1, '       cd %s\n', fileparts(which('pciaer_stim_mon')));
disp('       make mex');
disp(' ');
disp('   Note that you will need a compiled version of the PCI-AER library');
disp('   to link against.');
disp(' ');

% --- END of pciaer_stim_mon.m ---
