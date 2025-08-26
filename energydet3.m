clc; clear; close all;

%% Step 1: Record Audio (3 sec)
recObj = audiorecorder(44100,16,1);
disp('🎙️ Start speaking...');
recordblocking(recObj,3);
disp('✅ Recording finished!');
y = getaudiodata(recObj);
fs = 44100;
audiowrite('sample.wav',y,fs);

%% Step 2: Preprocess
[y,fs] = audioread('sample.wav');
y = y(:,1);             % mono
y = y / max(abs(y)+eps);    % normalization (eps to avoid /0)

%% Step 3: Silence Check
threshold = 0.005;   % silence energy threshold
signal_energy = sum(y.^2)/length(y);

if signal_energy < threshold
    disp('⚠️ No speech detected! Try to speak anything 🎤');
    return;  % stop execution if silence
end

%% Step 4: Feature Extraction
% Energy
energy = signal_energy;

% Pitch using autocorrelation
acf = xcorr(y);
acf = acf(length(y):end);
[~,loc] = max(acf(50:end)); % ignore 0-lag
pitch = fs/(loc+49);

%% Step 5: Rule-based Classification
if energy > 0.02 && pitch > 180
    emotion = 'Happy 😀';
elseif energy < 0.01 && pitch < 150
    emotion = 'Sad 😔';
else
    emotion = 'Angry 😡';
end

%% Step 6: Output
disp(['Detected Emotion: ',emotion]);

% Show Graphs
subplot(3,1,1), plot(y), title('Recorded Speech Signal');
subplot(3,1,2), plot(abs(fft(y))), title('FFT Spectrum');
subplot(3,1,3), bar([energy pitch]), set(gca,'XTickLabel',{'Energy','Pitch'});
title(['Extracted Features → ',emotion]);
