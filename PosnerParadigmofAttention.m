%variabeles
numberofrecs=16;%Better be a squared number
numberofleveltrial=1;
rt_valid=zeros(numberofleveltrial*numberofrecs*2,1);
rt_invalid=zeros(numberofleveltrial*numberofrecs*2,1);
rt_delay1=zeros(numberofleveltrial*numberofrecs*2,1);
rt_delay2=zeros(numberofleveltrial*numberofrecs*2,1);
delay=zeros(numberofleveltrial*numberofrecs*4,1);
valid=zeros(numberofleveltrial*numberofrecs*4,1);
numberoftrials=1;
numberoftrials_valid=1;
numberoftrials_invalid=1;
numberoftrials_delay1=1;
numberoftrials_delay2=1;
delay1=0.3;
delay2=0.1;
position_cue=zeros(numberofleveltrial*numberofrecs*2,4);
position_target=zeros(numberofleveltrial*numberofrecs*2,4);
horizontal_dist=zeros(numberofleveltrial*numberofrecs*2,0);
vertical_dist=zeros(numberofleveltrial*numberofrecs*2,0);
total_dist=zeros(numberofleveltrial*numberofrecs*2,0);


%Draw the plate
figure
for i=0:3
for j=0:3
rectangle('Position',[i j 1 1]);
end
end
xlim([-4 8])
ylim([-4 8])


%set handles to each rectangle
handles=cell(1,numberofrecs);
n=0;%solve the index problem
for i=0:3
     for j=0:3      
     eval(['x',num2str(i),num2str(j),'=rectangle(''Position'',[i j 1 1]);']);
     %handles(1,j)=xij
     eval(['handles(1,j+n+1)={x',num2str(i),num2str(j),'};']);
     end
     n=n+4;
end 



pause%wait for start command
%the experiment begins here
for m=1:4*numberofleveltrial
        sequence=randperm(numberofrecs); %random positions of cues
    %generate a sequences of 0 or 1s to make sure equal number of valid
    %and invalid trials/delay1 and delay2
    judge=zeros(1,numberofrecs);
    judge(1,1:numberofrecs/2)=1;
    [p,q]=size(judge);
    B1=randperm(q);B2=randperm(q);
    randjudge_delay=judge(:,B1);
    randjudge_valid=judge(:,B2);
for i=1:numberofrecs 
    set(handles{sequence(i)},'FaceColor','r');
if randjudge_delay(i)==1 %delay1 
    pause(delay1);
else
    pause(delay2);
end


%trial
if randjudge_valid(i)==1 %valid trial
    set(handles{sequence(i)},'FaceColor','b'); %the cue occurs
else %invalid trial, choose another random position
    while 1
        p=randi([1 numberofrecs]);
        if p==sequence(i)
            continue
        else
            break
        end
    end
    set(handles{p},'FaceColor','b');
end

%record reaction time
tic
pause
if randjudge_delay(i)==1&&randjudge_valid(i)==1
    rt_delay1(numberoftrials_delay1,1)=toc;
    rt_valid(numberoftrials_valid,1)=toc;
elseif randjudge_delay(i)==1&&randjudge_valid(i)==0
    rt_delay1(numberoftrials_delay1,1)=toc;
    rt_invalid(numberoftrials_invalid,1)=toc;
elseif randjudge_delay(i)==0&&randjudge_valid(i)==1
    rt_delay2(numberoftrials_delay2,1)=toc;
    rt_valid(numberoftrials_valid,1)=toc;
else 
    rt_delay2(numberoftrials_delay2,1)=toc;
    rt_invalid(numberoftrials_invalid,1)=toc;
end
if randjudge_delay(i)==1
    delay(numberoftrials,1)=delay1;
    numberoftrials_delay1=numberoftrials_delay1+1;
else
    delay(numberoftrials,1)=delay2;
    numberoftrials_delay2=numberoftrials_delay2+1;
end
if randjudge_valid(i)==1
    valid(numberoftrials,1)=1;
    numberoftrials_valid=numberoftrials_valid+1;
else
    valid(numberoftrials,1)=0;
    %record positions
    position_cue(numberoftrials_invalid,:)=get(handles{sequence(i)},'Position');
    position_target(numberoftrials_invalid,:)=get(handles{p},'Position');
    numberoftrials_invalid=numberoftrials_invalid+1;
end
%clear the plate
 set(handles{p},'FaceColor','w');
set(handles{sequence(i)},'FaceColor','w');
numberoftrials=numberoftrials+1;
end
end
numberoftrials=numberoftrials-1;

%data analysis
[va_significance,va_p]=ttest(rt_valid,rt_invalid);
[de_significance,de_p]=ttest(rt_delay1,rt_delay2);

%measurement of speed of the "scanner"
for i=1:numberofleveltrial*numberofrecs*2
    horizontal_dist(i,1)=abs(position_cue(i,1)-position_target(i,1));
    vertical_dist(i,1)=abs(position_cue(i,2)-position_target(i,2));
    total_dist(i,1)=norm(position_cue(i,:)-position_target(i,:));
end
subplot(2,2,1)
plot(horizontal_dist,rt_invalid,'.')
subplot(2,2,2)
plot(vertical_dist,rt_invalid,'.')
subplot(2,2,3)
plot(total_dist,rt_invalid,'.')
xlim([0 5])
subplot(2,2,4)
A=[rt_delay1,rt_delay2];
boxplot(A)