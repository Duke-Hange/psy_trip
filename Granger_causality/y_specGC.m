function f=y_specGC(data)
%%% Parameters
ntrials   = 1;     % number of trials
nvars     = 2;      % number of variables
ssmoact   = 9;      % SS model order
rhoa      = 0.95;   % AR spectral radius
rmi       = 0.5;    % residuals log-generalised correlation (multi-information)
% g = -log|R|. g = 0 yields zero correlation,g = [] is uniform random
% on space of correlation matrices
% VAR model order estimation
varmosel  = 'AIC';  % VAR model order selection ('ACT', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
varmomax  = 32;     % maximum model order for VAR model order selection
% SS model order estimation
ssmosel   = 'SVC';  % SS model order selection ('ACT', 'SVC', or supplied numerical value)
% MVGC (frequency domain)
fres      = 256;    % spectral MVGC frequency resolution (empty for automatic calculation)
if ~exist('seed',   'var'), seed     = 2000;    end % random seed (0 for unseeded)
rng_seed(seed);

X=data;
X = demean(X,true);

[varmoaic,varmobic,varmohqc,varmolrt] = tsdata_to_varmo(X,varmomax,'LWR',[],[],[]);
if varmoaic~=0
    varmo = varmoaic;
else
    varmo=1;
end
pf = 2*varmo; % Bauer recommends 2 x VAR model order
[ssmosvc,ssmomax] = tsdata_to_ssmo(X,pf,[]);
if ssmosvc~=0
    ssmo = ssmosvc;
else
    ssmo = 1;
end

[A,C,K,V] = tsdata_to_ss(X,pf,ssmo);
fabserr = ss_check_fres(A,C,K,V,fres);
f = ss_to_spwcgc(A,C,K,V,fres);




