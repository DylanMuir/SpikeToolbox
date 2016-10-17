function [stTrain] = STCreateFastPoisson(fFreq,tDuration,varargin)

% STCreate - FUNCTION Create a Poisson distributed spike train with constant mean frequency  
% $Id: STCreateFastPoisson.m 8602 2008-02-27 17:49:21Z dylan $
%
% Usage: [stTrain] = STCreateFastPoisson(<definition arguments>,
%                             <instantiation arguments>,
%                             <mapping arguments>)
%
% Usage: [stTrain] = STCreateFastPoisson(fFreq, tDuration, ...)
%        [stTrain] = STCreate(... <, nAddr1, nAddr2, ...>)
%        [stTrain] = STCreate(..., strTemporalType, tDuration <, stasSpecification, nAddr1, nAddr2, ...>)
%
% STCreateFastPoisson will create a Poisson distributed spike train with
% constant mean frequency, using a fast generation algorithm. 
%
% The first argument specifies the train's mean frequency, and the second 
% argument specifies its duration in seconds.
% If the optional set of additional arguments are provided, the train 
% will be mapped and 'stTrain' will contain a field 'mapping' containing 
% the mapped spike train.  See STMap for details of these arguments.

% Author: Giacomo Indiveri <giacomo@ini.phys.ethz.ch>
% Created: 27th June, 2007


% -- Basic argument checking

if (nargin < 2)
    disp('*** STCreate: incorrect usage');
    help STCreateFastPoisson;
    return;
end


% -- Pull apart the command line




duration=tDuration*1000; % spike train duration in ms
delta_t = 0.025; % resolution of spike train in ms

t = 0:delta_t:duration;
idur=length(t);
Vrandth = gamrnd(1,1,1,idur);
itonextspike =round(Vrandth/(fFreq/1000*delta_t));
itonextspike = itonextspike(itonextspike > 2); % refractory period = 0.002 ms
ispikes = cumsum(itonextspike);
ispikes = ispikes(ispikes < (duration/delta_t));
nspikes = length(ispikes);
spikes=(t(ispikes)/1000);

if (~isempty(spikes))
    [stTrain]=STCreateFromVector(spikes);
    if (nargin>2)
        if (nargin < 4)
            disp('*** STCreateFastPoisson: Not enough arguments to instantiate the constant train');
            help STCreateFastPoisson;
            return;
        end
        [stTrain]=STMap(stTrain,varargin{1},varargin{2});
    end
else
    stTrain=STNullTrain;
end


% --- END of STCreateFastPoisson.m ---
