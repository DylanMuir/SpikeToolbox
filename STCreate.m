function [stTrain] = STCreate(strType, varargin)

% FUNCTION STCreate - Create a spike train
%
% Usage: [stTrain] = STCreate('constant', fFreq, ...)
%        [stTrain] = STCreate('linear', fStartFreq, fEndFreq, ...)
%        [stTrain] = STCreate('sinusoid', fMinFreq, fMaxFreq, tPeriod, ...)
%        [stTrain] = STCreate(..., strTemporalType, tDuration)
%        [stTrain] = STCreate(..., strTemporalType, tDuration, nNeuron, nSynapse)
%
% STCreate will create a spike train definition of various types.  The first
% argument specifies the type of spike train, and must be one of {'constant',
% 'linear', 'sinusoid'}.  (See STCreateConstant, STCreateLinear and
% STCreateSinusoid for details of the parameters relating to the spike train
% types).  When called with only the train definition parameters, 'stTrain'
% will comprise of a single field 'defintion' containing the spike train
% definition.
%
% STCreate can also be used to instantiate and map the resulting spike train.
% By providing the parameters 'strTemporalType' (one of {'regular',
% 'poisson'}) and 'tDuration', the train will be instantiated and 'stTrain'
% will contain a field 'instance' containing the spike train instance.  See
% STInstaniate for details of these parameters.  By providing the paramters
% 'nNeuron' and 'nSynapse', the traini will be mapped and 'stTrain' will
% contain a field 'mapping' containing the mapped spike train.  See STMap for
% details of these parameters.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% $Id: STCreate.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Basic argument checking

if (nargin < 2)
    disp('*** STCreate: incorrect usage');
    help STCreate;
    return;
end


% -- Pull apart the command line

% - Default is not to instantiate the train, or map it to a synapse
bInstantiateTrain = false;
bMapTrain = false;

switch lower(strType)
    % - Constant frequency spike train
    case {'constant', 'c'}
        if (nargin > 6)
            disp('--- STCreate: Extra arguments ignored');
        end
        
        if (nargin < 2)
           disp('*** STCreate: Incorrect number of arguments for constant train');
           help STCreate;
           return;
        end
        
        if (nargin > 2)
            if (nargin < 4)
               disp('*** STCreate: Not enough arguments to instantiate the constant train');
               help STCreate;
               return;
            end   
            bInstantiateTrain = true;
            strTemporalType = varargin{2};
            tDuration = varargin{3};
        end
        
        if (nargin > 4)
            if (nargin < 6)
               disp('*** STCreate: Not enough arguments to map the constant train');
               help STCreate;
               return;
            end
            bMapTrain = true;
            nNeuron = varargin{4};
            nSynapse = varargin{5};
        end

        stTrain = STCreateConstant(varargin{1});
        
    
    % - Increasing spike train
    case {'linear', 'l'}
        if (nargin > 7)
            disp('--- STCreate: Extra arguments ignored');
        end
        
        if (nargin < 3)
           disp('*** STCreate: Incorrect number of arguments for linear train');
           help STCreate;
           return;
        end
        
        if (nargin > 3)
            if (nargin < 5)
               disp('*** STCreate: Not enough arguments to instantiate the linear train');
               help STCreate;
               return;
            end
            bInstantiateTrain = true;
            strTemporalType = varargin{3};
            tDuration = varargin{4};
        end
        
        if (nargin > 5)
            if (nargin < 7)
               disp('*** STCreate: Not enough arguments to map the linear train');
               help STCreate;
               return;
            end
            bMapTrain = true;
            nNeuron = varargin{5};
            nSynapse = varargin{6};
        end

        stTrain = STCreateLinear(varargin{1}, varargin{2});
        
        
    % - Sinusoidal spike train
    case {'sinusoid', 's'}
        if (nargin > 8)
            disp('--- STCreate: Extra arguments ignored');
        end
        
        if (nargin < 4)
           disp('*** STCreate: Incorrect number of arguments for sinusoidal train');
           help STCreate;
           return;
        end
        
        if (nargin > 4)
            if (nargin < 6)
               disp('*** STCreate: Not enough arguments to instantiate the sinusoidal train');
               help STCreate;
               return;
            end
            bInstantiateTrain = true;
            strTemporalType = varargin{4};
            tDuration = varargin{5};
        end
        
        if (nargin > 6)
            if (nargin < 8)
               disp('*** STCreate: Not enough arguments to map the sinusoidal train');
               help STCreate;
               return;
            end
            bMapTrain = true;
            nNeuron = varargin{6};
            nSynapse = varargin{7};
        end

        stTrain = STCreateSinusoid(varargin{1}, varargin{2}, varargin{3});
        
    % - Unknown train type
    otherwise
        disp('*** STCreate: Unknown spike train type.');
        disp('              Should be one of {constant, linear, sinusoid}');
        help STCreate;
        return;
end


% -- Instantiate train, if required

if (bInstantiateTrain)
    stTrain = STInstantiate(stTrain, strTemporalType, tDuration);
end


% -- Map train, if required

if (bMapTrain)
    stTrain = STMap(stTrain, nNeuron, nSynapse);
end


% --- END of STCReate.m ---

% $Log: STCreate.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.7  2004/05/04 09:40:06  dylan
% Added ID tags and logs to all version managed files
%