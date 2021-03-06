%% setup paths

%pdstoolsdir = '~/Documents/MATLAB/pdstools_ajl/';
pdstoolsdir = '/Users/Aaron/pdstools_ajl/';

addpath(pdstoolsdir)
addpath(fullfile(pdstoolsdir, 'dependencies'))

plxname = '/Users/Aaron/Dropbox/twagData/pat/ephys/p20150827twag.plx';
pdsfile = '/Users/Aaron/Dropbox/twagData/pat/late biased/20150827/pat20150827twag1534.PDS';

% plxname = '/Users/Aaron/Dropbox/twagData/pat/ephys/p20150903twag.plx';
% pdsfile = '/Users/Aaron/Dropbox/twagData/pat/late biased/20150903/pat20150903twag1407.PDS';

%% load files, get timing
load(pdsfile, '-mat')

pl = readPLXFileC(plxname, 'all');
spikes = plx.getSpikes(pl, 1, 0);
[events, strobed] = plx.getEvents(pl);

[plxtrialstart, plxtrialstop] = plx.pdsTrialTimes(PDS, strobed, events);
%% test out some events
[m,s,bc]=pdsa.eventPsth(spikes.time(spikes.id==2), events.time(events.id==3), [-.5 1.5], .001, ones(100,1)/100);
figure
plot(bc, m)

% plot ptsh for different coherence distributions
centeringField='motionon';
win=[-.5 1.5];
centerTime=PDS.timing.(centeringField);
centerTime=centerTime(:,1)+plxtrialstart;

stimDist = PDS.stimDistNum(:);
ii = 1;
ixix     = [1 5 2 4 3];

figure; hold on
for ii = 1:length(ixix)
    distIx   = stimDist(:)==ixix(ii);

    [m1,~,bc, ~, ~]=pdsa.eventPsth(spikes.time(spikes.id==2), centerTime(distIx), win, .001, ones(100,1)/100);
    if ii == 5
        plot(bc, m1, 'k')
    else
        plot(bc, m1)
    end
end

legend('strL', 'strR', 'wkL', 'wkR', 'rc'); 

%% PSTH arrange by targ choice (and coherence distribution)

T1ix=PDS.targ1Chosen(:)==1 & PDS.stimDistNum(:)==3;
T2ix=PDS.targ1Chosen(:)==0 & PDS.stimDistNum(:)==3;

centeringField='motionon';
win=[-.5 1.5];
centerTime=PDS.timing.(centeringField);
centerTime=centerTime(:,1)+plxtrialstart;


[m1,s1,bc, ~, trSpkCnt1]=pdsa.eventPsth(spikes.time(spikes.id==2), centerTime(T1ix), win, .001, ones(100,1)/100);
[m2,s2, ~, ~, trSpkCnt2]=pdsa.eventPsth(spikes.time(spikes.id==2), centerTime(T2ix), win, .001, ones(100,1)/100);

figure
%subplot(1,2,1)
plot(bc, m1, 'r', bc, m2, 'b', ...
    bc, m1+s1, 'r--', bc, m1-s1, 'r--', ...
    bc, m2+s2, 'b--', bc, m2-s2, 'b--')
%subplot(1,2,2)
%plot(bc, m1-m2, 'k')

%% CP stuff

%histograms
trialSpikes1 = sum(trSpkCnt1,2);
trialSpikes2 = sum(trSpkCnt2,2);

figure; hold on
hist(trialSpikes1)
set(get(gca,'child'),'FaceColor','none','EdgeColor','k');
hist(trialSpikes2)

%time course
allTrSpikes = [trSpkCnt1; trSpkCnt2];
allTrChoice = [ones(size(trSpkCnt1, 1),1); zeros(size(trSpkCnt2, 1),1)];

[mCP,sCP] = choiceProbabilityCalculate(allTrSpikes, allTrChoice);
figure; hold on
plot(bc, mCP, 'k') 
%      bc, mCP+sCP, 'k--',...
%      bc, mCP-sCP, 'k--');



