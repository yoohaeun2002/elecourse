% <  1. 음성 파일 읽고 재생하기  >

filename = './0525.wav';
% 데이터를 읽고 샘플링된 데이터 y와 이 데이터의 샘플 레이트 Fs를 반환
[audioData,fs] = audioread(filename);



%----------------------
% < 2. waveform 그리기 > 

% 오디오 파일의 정보를 불러옴
auInfo = audioinfo(filename);

% 오디오 파일의 최소 및 최대 엔벨로프(envelope)와 위치를 계산
% audioEnvelope(filename, NumPoints=2000) 함수는 오디오 신호의 엔벨로프를 계산
% 여기서 엔벨로프는 신호의 진폭 변화를 나타내며, 최소값과 최대값이 반환
[envMin, envMax, loc] = audioEnvelope(filename, NumPoints=2000);

% 오디오 파일의 채널 수를 계산
nChans = size(envMin, 2);

% 엔벨로프 값을 3차원 배열로 변환
envbars = [shiftdim(envMin, -1);
           shiftdim(envMax, -1);
           shiftdim(NaN(size(envMin)), -1)];

% 엔벨로프 값을 2차원 배열로 변환하여 y 축 데이터로 사용
ybars = reshape(envbars, [], nChans);

% 시간 값을 초 단위로 변환하여 x 축 데이터로 사용
t = seconds(loc / auInfo.SampleRate);
tbars = reshape(repmat(t, 3, 1), [], 1);

% 오디오 엔벨로프를 플로팅
% 변환된 시간 및 엔벨로프 값을 사용하여 waveform을 플로팅
plot(tbars, ybars);
title(filename, Interpreter="none")
xlabel("Time")
ylabel("Amplitude")
%  x 축의 범위를 자동으로 조정하여 waveform을 보다 명확하게 표시
xlim("tight")
% y 축의 범위를 -1에서 1로 설정하여 waveform의 진폭을 표준화
ylim([-1 1])

%----------------------
% < 3. spectrogram  그리기 > 


% 창(window) 크기 설정
window = 1024;

% 창 겹침(overlap) 설정
noverlap = window / 2;

% FFT 점 수 설정
nfft = 1024;

% 오디오 데이터의 전체 지속 시간 계산
duration = length(audioData) / fs;

% 시간 벡터 생성
time = linspace(0, duration, length(audioData));

figure;

% 스펙트로그램 계산 및 플로팅
% s = spectrogram(x,window,noverlap,nfft)는 nfft개 샘플링 점을 사용하여 이산 푸리에 변환을 계산
spectrogram(audioData, window, noverlap, nfft, fs, 'yaxis');


title('Spectrogram of Audio File');
xlabel('Time (s)');
ylabel('Frequency (kHz)');

% y축 틱 값을 가져옴
yt = get(gca, 'YTick');

% y축 틱 값을 kHz 단위로 변환하여 레이블 설정
set(gca, 'YTickLabel', yt / 1000);

% 색상 막대를 추가
colorbar;

%----------------------
% < 4. peak 검출 > 


% % 오디오 데이터의 크기 확인
% N = length(audioData);
% 
% % 스펙트럼 계산
% Y = fft(audioData); % 이산 푸리에 변환을 계산
% P2 = abs(Y/N); % 스펙트럼의 크기(진폭)를 계산하고 정규화
% P1 = P2(1:N/2+1); % 양수 주파수 성분만을 추출
% P1(2:end-1) = 2*P1(2:end-1); % 양수 주파수 성분을 보정
% 
% % 각 주파수 성분에 대응하는 주파수 벡터를 생성
% f = fs*(0:(N/2))/N;
% 
% % Peak 검출
% % findpeaks() >  스펙트럼에서 피크를 찾고, 각 피크의 위치를 반환
% %                MinPeakDistance는 피크 간 최소 거리를 설정
% 
% % 최소 피크 높이 설정 (미미한 신호 무시)
% minPeakHeight = max(P1) * 0.01;  % 최대 피크 높이의 1%로 설정하여 작은 신호를 걸러냄
% 
% % Peak 검출
% [~, locs] = findpeaks(P1, 'MinPeakDistance', 1000, 'MinPeakHeight', minPeakHeight);
% 
% % Peak 주파수 및 높이 출력
% peak_frequencies = f(locs);
% peak_heights = P1(locs);
% disp('Detected Peaks:');
% for i = 1:length(peak_frequencies)
%     fprintf('Peak %d: 주파수 %.2f Hz, 높이 %.2f\n', i, peak_frequencies(i), peak_heights(i));
% end
% 
% % 음성 신호 해석
% % 각 피크 주파수를 분석하여 소리의 높낮이를 해석
% % 주파수가 500 Hz 미만이면 '낮은 소리', 500 Hz와 1500 Hz 사이면 '중간 소리', 1500 Hz 이상이면 '높은 소리'로 분류
% % fprintf를 사용하여 해석 결과를 출력
% for i = 1:length(peak_frequencies)
%     if peak_frequencies(i) < 500
%         interpretation = '낮은 소리';
%     elseif peak_frequencies(i) > 500 && peak_frequencies(i) < 1500
%         interpretation = '중간 소리';
%     else
%         interpretation = '높은 소리';
%     end
%     fprintf('Peak %d: 주파수 %.2f Hz - %s\n', i, peak_frequencies(i), interpretation);
% end

%----------------------
% % < 5. 스펙트럼 및 Peak 시각화 > 
% figure;
% % 주파수 벡터 f와 스펙트럼 P1을 플로팅
% plot(f, P1);
% hold on;
% plot(f(locs), P1(locs), 'ro', 'MarkerSize', 10);
% hold off;
% xlabel('Frequency (Hz)');
% ylabel('Magnitude');
% title('Spectrum with Detected Peaks');
% legend('Spectrum', 'Peaks');
% xlim([0 5000]); % x축을 0Hz에서 10000Hz로 제한
%----------------------
% < 6. 주파수 변조 및 원본 신호와의 비교 > 


% 음성 파일 읽기 및 전처리
[audioIn, fs] = audioread('./0525.wav');
audioIn = mean(audioIn, 2); % 스테레오를 모노로 변환

% 원래 신호의 웨이브폼과 스펙트로그램 표시
figure;
subplot(2,2,1);
plot((1:length(audioIn))/fs, audioIn);
title('Original Waveform');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,2,2);
spectrogram(audioIn, 256, [], [], fs, 'yaxis');
title('Original Spectrogram');

% 원래 신호 재생
disp('Playing original audio...');
sound(audioIn, fs);
pause(length(audioIn)/fs + 1); % 오디오 재생 시간 대기

gender = lower(input('Enter the gender of the speaker (male/female): ', 's'));

% 입력된 성별에 따라 피치 변조 비율 설정
if strcmp(gender, 'male')
    disp('Input Gender: Male');
    pitchShiftFactor = 1.25; % 
    disp(pitchShiftFactor);
elseif strcmp(gender, 'female')
    disp('Input Gender: Female');
    pitchShiftFactor = 0.8; %
    disp(pitchShiftFactor);
else
    error('Invalid gender input. Please enter "male" or "female".');
end

% 피치 변환 적용
pitchShiftedAudio = pitchShift(audioIn, fs, pitchShiftFactor);

% 변환된 오디오 저장
audiowrite('output_audio.wav', pitchShiftedAudio, fs);

% 변환된 신호의 웨이브폼과 스펙트로그램 표시
subplot(2,2,3);
plot((1:length(pitchShiftedAudio))/fs, pitchShiftedAudio);
title('Pitch-Shifted Waveform');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,2,4);
spectrogram(pitchShiftedAudio, 256, [], [], fs, 'yaxis');
title('Pitch-Shifted Spectrogram');

% 변환된 신호 재생
disp('Playing pitch-shifted audio...');
sound(pitchShiftedAudio, fs);
pause(length(pitchShiftedAudio)/fs + 1); % 오디오 재생 시간 대기

% 피치 변환 함수
% 시간 축 스케일링을 통해 주파수를 변경하는 함수
% 신호의 샘플을 더 촘촘히(피치 높임) 또는 더 넓게(피치 낮춤) 배치하여 신호의 주파수 성분을 조정
% 선형 보간법을 사용하여 새로운 샘플을 계산함으로써 신호의 연속성을 유지하고 왜곡을 최소화

% audioIn: 원래의 오디오 신호 (모노 신호)
% fs: 샘플링 주파수
% factor: 피치 변조 비율 (1보다 크면 낮은 피치, 1보다 작으면 높은 피치)

    % interp1() >  선형 보간법을 사용하여 원래 신호 audioIn을 새로운 시간 벡터 t에 맞춰 리샘플링
    %               원래 샘플 인덱스 (1:len)에서 새로운 시간 벡터 t에 대응하는 값들을 계산하여
    %               shiftedAudio에 저장-> pitch가 변조된 신호 생성 

% 피치 변환 함수
function shiftedAudio = pitchShift(audioIn, fs, factor)
    % 신호의 길이 및 시간 벡터 생성
    len = length(audioIn);
    t = (1:len) * factor; % 시간 스케일링

    % 선형 보간법을 사용하여 시간 축 스케일링 적용
    shiftedAudio = interp1((1:len)', audioIn, t', 'linear');

    % NaN 값을 0으로 대체 (필요한 경우)
    shiftedAudio(isnan(shiftedAudio)) = 0;

    % 출력 신호의 길이를 원래 신호와 동일하게 조정
    if length(shiftedAudio) < len
        % 길이가 부족한 경우, 마지막 샘플을 반복하여 길이를 맞춤
        shiftedAudio = [shiftedAudio; repmat(shiftedAudio(end), len - length(shiftedAudio), 1)];
    else
        % 길이가 충분한 경우, 앞부분만 사용하여 길이를 맞춤
        shiftedAudio = shiftedAudio(1:len);
    end
end