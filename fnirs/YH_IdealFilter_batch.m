function [data2, ylpf]=YH_IdealFilter_batch(data,hpf,lpf,fs)
    y2 = y;
    % Check for NaN
    if max(max(isnan(y)))
       warning('Input to hmrR_BandpassFilt contains NaN values. Add hmrR_PreprocessIntensity_NAN to the processing stream.');
       return
    end
    % Check for finite values
    if max(max(isinf(y)))
       warning('Input to hmrR_BandpassFilt must be finite.');
       return
    end

    % Check that cutoff < nyquist
    if lpf / (fs / 2) > 1 || hpf / (fs / 2) > 1
        warning(['hmrR_BandpassFilt cutoff cannot exceed the folding frequency of the data with sample rate ', num2str(fs), ' hz.']);
        return
    end
    
    % low pass filter
    lpf_norm = lpf / (fs / 2);
    if lpf_norm > 0  % No lowpass if filter is 
        FilterOrder = 3;
        [z, p, k] = butter(FilterOrder, lpf_norm, 'low');
        [sos, g] = zp2sos(z, p, k);
        y2 = filtfilt(sos, g, double(y)); 
    end
    
    % high pass filter
    hpf_norm = hpf / (fs / 2);
    if hpf_norm > 0
        FilterOrder = 5;
        [z, p, k] = butter(FilterOrder, hpf_norm, 'high');
        [sos, g] = zp2sos(z, p, k);
        y2 = filtfilt(sos, g, y2);
    end
    
    data2(ii).SetDataTimeSeries(y2);
    
end

% 	brain_data		    -	brain_data to process
%   output_path         -   brain_data path to save
% 	TR	                -   time interval of brain_data points
%   Band            -   The frequency for filtering, 1*2 Array. Could be:
%                   [LowCutoff_HighPass HighCutoff_LowPass]: band pass filtering
%                   [0 HighCutoff_LowPass]: low pass filtering
%                   [LowCutoff_HighPass 0]: high pass filtering
% brain_data ¡úNtimepoints * Nvox
dim = size(brain_data);
% brain_data = reshape(brain_data, [], dim(4))';   % reshape and transpose --  Ntimepoints * Nvox
LowCutoff_HighPass = Band(1);
HighCutoff_LowPass = Band(2);
sampleLength = size(brain_data,1);
paddedLength = 2^nextpow2(sampleLength);
    tic
    % Get the frequency index
    if (LowCutoff_HighPass >= sampleFreq/2) % All high stop
        idxLowCutoff_HighPass = paddedLength/2 + 1;
    else % high pass, such as freq > 0.01 Hz
        idxLowCutoff_HighPass = ceil(LowCutoff_HighPass * paddedLength /sampleFreq + 1);
    end
    
    if (HighCutoff_LowPass>=sampleFreq/2)||(HighCutoff_LowPass==0) % All low pass
        idxHighCutoff_LowPass = paddedLength/2 + 1;
    else % Low pass, such as freq < 0.08 Hz
        idxHighCutoff_LowPass = fix(HighCutoff_LowPass * paddedLength/sampleFreq  + 1);
    end
    
    FrequencyMask = zeros(paddedLength,1);
    FrequencyMask(idxLowCutoff_HighPass:idxHighCutoff_LowPass,1) = 1;
    FrequencyMask(paddedLength-idxLowCutoff_HighPass+2:-1:paddedLength-idxHighCutoff_LowPass+2,1) = 1;
    
    FrequencySetZero_Index = find(FrequencyMask==0);
    
    %Remove the mean before zero padding
    brain_data = brain_data - repmat(mean(brain_data),size(brain_data,1),1);
    
    brain_data = [brain_data;zeros(paddedLength -sampleLength,size(brain_data,2))]; %padded with zero
    
    brain_data = fft(brain_data);
    
    brain_data(FrequencySetZero_Index,:) = 0;
    
    brain_data = ifft(brain_data);
    
    Data_Filtered = brain_data(1:sampleLength,:);
    
    brain_filtered=reshape(Data_Filtered',dim(1),dim(2));
    
    mkdir(output_path)
    cd(output_path)
    fname = strcat(Band,'_Filtered');
    save('band.mat','brain_filtered');
    toc