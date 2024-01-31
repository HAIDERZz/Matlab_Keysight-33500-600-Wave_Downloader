function arbTo33xxx(connect,addr,arb,channel,amp,offset,sRate,name)
%This function connects to a 33500/33600 waveform generator and sends it an
%arbitrary waveform from Matlab via LAN or USB. The input arguments are as
%follows:
%connect --> TCP, set connect = 1. USB, set connect = 0;
%addr--> TCP/USB  address (string) of the 33500/33600 that you want to send the waveform to
%arb --> a vector of the waveform points that will be sent to a 33500/33600
%waveform generator
%channel --> if channel 1, please set channel = 1; if channel 2,  set channel = 0;
%amp --> amplitude of the arb waveform as Vpp
%offset --> offset of the arb waveform
%sRate --> sample rate of the arb waveform
%name --> The same of the arb waveform as a string
%Note: this function requires the instrument control toolbox

%build visa address string to connect
if  connect
vAddress = ['TCPIP0::' addr '::inst0::INSTR'];
else
vAddress = ['USB0::' addr '::0::INSTR'];
end

%open connection to 33500 or 33600 waveform generator
try
   fgen = visadev(vAddress);
   fgen.Timeout = 15;
catch exception %problem occurred throw error message
    uiwait(msgbox('Error occurred trying to connect to the 33522, verify correct IP address','Error Message','error'));
    rethrow(exception);
end

%calculate output buffer size
buffer = length(arb)*8;
set (fgen,'OutputBufferSize',(buffer+125));

%Query Idendity string and report
writeline (fgen, '*IDN?');
idn = readline (fgen);
fprintf (idn)
fprintf ('\n\n')

%create waitbar for sending waveform to 33500
mes = ['Connected to ' idn ' sending waveforms.....'];
h = waitbar(0,mes);

%Reset instrument
writeline(fgen, '*RST');

%make sure waveform data is in column vector
if isrow(arb) == 0
    arb = arb';
end

%set the waveform data to single precision
arb = single(arb);

%scale data between 1 and -1
mx = max(abs(arb));
arb = (1*arb)/mx;

%update waitbar
waitbar(.1,h,mes);
if channel
%send waveform to 33500
writeline(fgen, 'SOURce1:DATA:VOLatile:CLEar'); %Clear volatile memory
writeline(fgen, 'FORM:BORD SWAP');  %configure the box to correctly accept the binary arb points
arbBytes=num2str(length(arb) * 4); %# of bytes
header= ['SOURce1:DATA:ARBitrary ' name ', #' num2str(length(arbBytes)) arbBytes]; %create header
binblockBytes = typecast(arb, 'uint8');  %convert datapoints to binary before sending
write(fgen, [header binblockBytes], 'uint8'); %combine header and datapoints then send to instrument
writeline(fgen, '*WAI');   %Make sure no other commands are exectued until arb is done downloadin
%update waitbar
waitbar(.8,h,mes);
%Set desired configuration for channel 1
command = ['SOURce1:FUNCtion:ARBitrary ' name];
%fprintf(fgen,'SOURce1:FUNCtion:ARBitrary GPETE'); % set current arb waveform to defined arb testrise
writeline(fgen,command); % set current arb waveform to defined arb testrise
command = ['MMEM:STOR:DATA1 "INT:\' name '.arb"'];
%fprintf(fgen,'MMEM:STOR:DATA1 "INT:\GPETE.arb"');%store arb in intermal NV memory
writeline(fgen,command);
%update waitbar
waitbar(.9,h,mes);
command = ['SOURce1:FUNCtion:ARB:SRATe ' num2str(sRate)]; %create sample rate command
writeline(fgen,command);%set sample rate
writeline(fgen,'SOURce1:FUNCtion ARB'); % turn on arb function
command = ['SOURce1:VOLT ' num2str(amp)]; %create amplitude command
writeline(fgen,command); %send amplitude command
command = ['SOURce1:VOLT:OFFSET' num2str(offset)];%create offset command
writeline(fgen,command); % set offset
writeline(fgen,'OUTPUT1 ON'); %Enable Output for channel 1
fprintf('Arb waveform downloaded to channel \n\n') %print waveform has been downloaded
else
%send waveform to 33500
writeline(fgen, 'SOURce2:DATA:VOLatile:CLEar'); %Clear volatile memory
writeline(fgen, 'FORM:BORD SWAP');  %configure the box to correctly accept the binary arb points
arbBytes=num2str(length(arb) * 4); %# of bytes
header= ['SOURce2:DATA:ARBitrary ' name ', #' num2str(length(arbBytes)) arbBytes]; %create header
binblockBytes = typecast(arb, 'uint8');  %convert datapoints to binary before sending
write(fgen, [header binblockBytes], 'uint8'); %combine header and datapoints then send to instrument
writeline(fgen, '*WAI');   %Make sure no other commands are exectued until arb is done downloadin
%update waitbar
waitbar(.8,h,mes);
%Set desired configuration for channel 1
command = ['SOURce2:FUNCtion:ARBitrary ' name];
%fprintf(fgen,'SOURce1:FUNCtion:ARBitrary GPETE'); % set current arb waveform to defined arb testrise
writeline(fgen,command); % set current arb waveform to defined arb testrise
command = ['MMEM:STOR:DATA2 "INT:\' name '.arb"'];
%fprintf(fgen,'MMEM:STOR:DATA1 "INT:\GPETE.arb"');%store arb in intermal NV memory
writeline(fgen,command);
%update waitbar
waitbar(.9,h,mes);
command = ['SOURce2:FUNCtion:ARB:SRATe ' num2str(sRate)]; %create sample rate command
writeline(fgen,command);%set sample rate
writeline(fgen,'SOURce2:FUNCtion ARB'); % turn on arb function
command = ['SOURce2:VOLT ' num2str(amp)]; %create amplitude command
writeline(fgen,command); %send amplitude command
command = ['SOURce2:VOLT:OFFSET' num2str(offset)];%create offset command
writeline(fgen,command); % set offset
writeline(fgen,'OUTPUT2 ON'); %Enable Output for channel 1
fprintf('Arb waveform downloaded to channe2 \n\n') %print waveform has been downloaded
end

%get rid of message box
waitbar(1,h,mes);
delete(h);

% %Read Error
% writeline(fgen, 'SYST:ERR?');
% errorstr = readline (fgen);

% error checking
% if strncmp (errorstr, '+0,"No error"',13)
%    errorcheck = 'Arbitrary waveform generated without any error\n';
%    fprintf (errorcheck)
% else
%    errorcheck = ['Error reported: ', errorstr];
%    writeline (errorcheck)
% end

clear fgen;