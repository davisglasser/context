%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Experimental program for asymmetric brightness matching               %%  
%% Measure the influence of background luminance                         %%
%% Display: 2 circles (inset) within larger circles (surround/background)%%
%% 
%% set on left & right side of screen. Observers adjust the luminance of %% 
%% the right inset to match the luminance of the left inset (aka target);%%
%% The surround of the target (left) is varied in luminance while the    %%
%% target and surround of matching inset (right) remains constant. There %%
%% are 5 different luminance values for the target surround & 3 reps for %%
%% the 5 conditions (blocked to prevent adaptation confound);            %%
%% Created by Sammy Hong 07/23/08; Modified by Eunice Yang 7/25/08       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [avgLumRed] = brightnessMatching(initials, practice, wContext)

HideCursor;

%clear all; screen('closeall'); %REMOVE
%initials='test'; %REMOVE
tme = clock; %REMOVE
%practice=0;%REMOVE
%wContext=1;%REMOVE

try
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%   Experiment Variables and parameters                   %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
   %%% EXPERIMENT PARAMETERS
   numConds=5; %5 background conditions
   if practice==1 | wContext==0
       numReps=1;
   else %experimental condition
        numReps=3; %3 reps per background condition
   end;
    
    Matched_RGB = zeros(numConds, numReps);
    Matched_lum = zeros(numConds, numReps);
    condOrder = randperm(numConds);
   
    %%% RESPONSE KEYS
    KbName('UnifyKeyNames');
    trialStart = KbName('space');
    trialEnd= KbName('Return');
    lumIncrease = KbName('UpArrow');
    lumDecrease = KbName('DownArrow');
    
    %%% WINDOW VARIABLES
    screens=Screen('Screens'); %REMOVE
    screenNumber=max(screens); %REMOVE
    w=Screen('OpenWindow',screenNumber,0,[],[],2); %REMOVE
    screen_rect = Screen('Rect',w); %REMOVE

    Screen('TextSize',w,35);
    Screen('TextFont',w,'Helvetica');%REMOVE
    Screen('TextStyle',w,1);%REMOVE

    load 'linearizedCLUT_082008';%REMOVE
    Screen('LoadNormalizedGammaTable',screenNumber, linearizedCLUT);%REMOVE
    Screen('FillRect',w, 0); %REMOVE
    Screen('Flip', w); %REMOVE
     
%    OpenScreensCalib;
    load 'CdLumFit_082008';
    
    %%% LUMINANCE / RGB PARAMETERS
    background=0;
    des_Inducing_bg_lum = [8 12 16 20 24]; %cd/m2 (based on CdLumFit);
    
    for j= 1:length(des_Inducing_bg_lum);
        temp= abs(des_Inducing_bg_lum(j)-CdLumFit); %subtract desired value from each to find closest match
        Inducing_bg_lum(j)= CdLumFit(find(min(temp)==temp));%equals 8,12,16,20,24 cd/m2 (based on CdLumFit);
        Inducing_bg_RGB(j)= find(CdLumFit==Inducing_bg_lum(j)); %RGB equivalent to lum; background of target stimulus
    end;
    
    des_Target_lum=6; %target luminance to match to; (based on CdLumFit); REMAINS CONSTANT
    temp= abs(des_Target_lum-CdLumFit);
    Target_lum= CdLumFit(find(min(temp)==temp));% equals 6cd/m2; 
    Target_RGB= find(CdLumFit==Target_lum);%RGB equivalent to target lum;
    
    Matching_bg_RGB = Inducing_bg_RGB(j);% equals 24cd/m2; background of stimulus being changed; REMAINS CONSTANT
 
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%    RECT setting          		     			  %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ppd = 40;
    BG_size = ppd*5;
    Field_size = ppd*1;
    
    sr_hor=screen_rect(3)/2; %REMOVE
    
    left_rect = [0 0 sr_hor screen_rect(4)];
    right_rect = [sr_hor+1 0 screen_rect(3:4)];

    leftMiddle = sr_hor - sr_hor/2;
    rightMiddle = sr_hor + sr_hor/2+1;
    
    Matching_bg_rect = CenterRect(SetRect(0,0,BG_size, BG_size), right_rect);
    Matching_field_rect = CenterRect(SetRect(0,0,Field_size, Field_size), right_rect);
    Inducing_bg_rect = CenterRect(SetRect(0,0,BG_size, BG_size), left_rect);
    Target_rect = CenterRect(SetRect(0,0,Field_size, Field_size), left_rect);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%    Matching Experiment        				  %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    for j = 1:numConds
        current_bg_RGB = Inducing_bg_RGB(condOrder(j));
        
        for k = 1:numReps;
            doneMatching = 0;
            Delta_Y = 0.2; % step size for increasing/decreasing luminance
 
            %temp2= CdLumFit(find(CdLumFit<15)); %choose all lum values less than 13;
            %posInitVals= [temp2(find(temp2<4)) temp2(find(temp2>8))]; %choose all values less than 5 but greater than 7 (less than 15)

            if wContext==1
               RGBmats= [current_bg_RGB, Matching_bg_RGB, Target_RGB]; %all center/surrounds that are held constant
               RGBrects= [Inducing_bg_rect' Matching_bg_rect'  Target_rect' Matching_field_rect'];%their corresponding rects (including matching center)
            else %no context
                RGBmats= [Target_RGB];
                RGBrects=[Target_rect' Matching_field_rect'];
            end;
            
            %initial_lum(j,k)=Sample(posInitVals);%CdLumFit(find(CdLumFit<13))); %find closest luminance match to currentLum in CdLumFit
            %initialMatch_RGB(j,k)= find(CdLumFit==initial_lum(j,k)); %find RGB that correspond to closest lum match

            if ~wContext
                temp= abs((Sample([2 16]))-CdLumFit); %start w/ large diffs
            else
                temp= abs((Sample([2 4 8 10 12 14]))-CdLumFit); %subtract desired value from each to find closest match
            end;
            initial_lum(j,k)= CdLumFit(find(min(temp)==temp)); %find closest luminance match to currentLum in CdLumFit
            initialMatch_RGB(j,k)= find(CdLumFit==initial_lum(j,k)); %find RGB that correspond to closest lum match

            currentLum = initial_lum(j,k);
            currentRGB = initialMatch_RGB(j,k);
            
            
            if j==1 & k==1; %first trial
                if wContext
                    Screen('DrawText', w, 'Task: Change the brightness of the right CENTER circle to match the',50,150,255);
                    Screen('DrawText', w, '         brightness of the left CENTER circle.', 50,200,255);
                else
                    Screen('DrawText', w, 'Task: Change the brightness of the right circle to match the brightness of the',50,150,255);
                    Screen('DrawText', w, '         left circle.',50,200,255);
                end
                Screen('DrawText', w, 'Press the UP arrow key to make the circle brighter and the DOWN arrow key', 50,Inducing_bg_rect(4)+100,255);
                Screen('DrawText', w, 'to make it dimmer.',50,Inducing_bg_rect(4)+150,255);
                if practice
                    Screen('DrawText', w, '*** PRACTICE ***',sr_hor-100, screen_rect(4)-100,[255 0 0]);
                end;
                SCREEN(w, 'DrawText', 'Press the space key to BEGIN.',50, Inducing_bg_rect(4)+225, 255);
                Screen('FillOval', w, [repmat([RGBmats currentRGB],3,1)], RGBrects); 
            else;
                SCREEN(w, 'DrawText', 'Press the space key for next trial.', 400, 380, 255);
            end;
            SCREEN('Flip', w);
            while 1
                [keyIsDown, secs, keyCode]= KbCheck;
                if keyCode(trialStart)
                    break;
                end
            end
        
            FlushEvents('keyDown');
            ListenChar(2);
            
            while ~ doneMatching;
                Screen('FillOval', w, [repmat([RGBmats currentRGB],3,1)], RGBrects); 
                Screen(w, 'DrawText', 'Press the return key when you are done.', 350, Inducing_bg_rect(4)+50, 255);
                Screen('Flip', w);
                
                Kbwait;
                [keyIsDown, secs, keyCode] = KbCheck;
                if keyCode(lumIncrease)
                    if currentLum + Delta_Y > max(CdLumFit);
                        Sysbeep(1);
                    else
                        temp= abs((currentLum+Delta_Y)-CdLumFit); %subtract desired value from each to find closest match
                        currentLum= CdLumFit(find(min(temp)==temp)); %find closest luminance match to currentLum in CdLumFit
                        currentRGB= find(CdLumFit==currentLum); %find RGB that correspond to closest lum match
                    end;

                elseif keyCode(lumDecrease)
                    if currentLum - Delta_Y < 0;
                        Sysbeep(1);
                    else
                        temp= abs((currentLum-Delta_Y)-CdLumFit); %subtract desired value from each to find closest match
                        currentLum= CdLumFit(find(min(temp)==temp)); %find closest luminance match to currentLum in CdLumFit
                        currentRGB= find(CdLumFit==currentLum); %find RGB that correspond to closest lum match
                    end
                elseif keyCode(trialEnd(1))
                    doneMatching=1;
                end;
                WaitSecs(.1);
            end
            
            ListenChar(1);
            Matched_RGB(condOrder(j),k) =currentRGB;
            Matched_lum(condOrder(j),k) =currentLum;

            %Sysbeep(3);
            
            if wContext==0
                if abs(Matched_lum(condOrder(j),k)-Target_lum)<1;
                    Screen(w, 'DrawText', 'Excellent job!', 400, 300, 255);
                else
                    Screen(w, 'DrawText', 'Try to match it closer.', 400, 300, 255);
                end;
            end;
        end
    end

    Screen('Flip', w);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%    OUTPUT FILE                                  %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if practice==0;

        fid = fopen(strcat(initials,'_',int2str(tme(2)),'_',int2str(tme(3))),'a');
        fprintf(fid,'--------------------------------------------------\n');
        fprintf(fid,'%s\t%02.0f/%02.0f/%4.0f\t%02.0f:%02.0f\n',initials,tme(2),tme(3),tme(1),tme(4),tme(5));

        if wContext==0;;
            fprintf(fid,'Surround Luminance Illusion- no Surround\n');
            fprintf(fid,' --> BG(cd/m2) Rep1\t Diff\n');
            for j=1:numConds;
                diffTargMatchNoContext(j)=  Target_lum- Matched_lum(j,1:numReps);
                fprintf(fid,' --> %5.2f\t%5.2f\t%5.2f\n', Inducing_bg_lum(j), Matched_lum(j,1:numReps),diffTargMatchNoContext(j));
            end;
            fprintf(fid,' --> Percent mean difference in no context condition= %5.2f%%\n', 100*(mean(diffTargMatchNoContext)/Target_lum));
        else
            fprintf(fid,'Surround Luminance Illusion\n');
            fprintf(fid,' --> BG(cd/m2)\t Rep1\t Rep2\t Rep3\t Mean\t Diff\n');
            for j= 1:numConds;
                diffTargMatch(j)= Target_lum - mean(Matched_lum(j,1:numReps));
                fprintf(fid,' --> %5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\n', Inducing_bg_lum(j), Matched_lum(j,1:numReps), mean(Matched_lum(j,1:numReps)),diffTargMatch(j));
            end;
            avgLumRed= 100*(mean(diffTargMatch)/Target_lum);
            fprintf(fid,' --> Mean Luminance Reduction = %5.2f%%\n',avgLumRed);
            fprintf(fid,'--------------------------------------------------\n\n');

            %Display in command window
            fprintf('--------------------------------------------------\n');
            fprintf('%s\t%02.0f/%02.0f/%4.0f\t%02.0f:%02.0f\n',initials,tme(2),tme(3),tme(1),tme(4),tme(5));
            fprintf('Surround Luminance Illusion\n');
            fprintf(' --> BG(cd/m2)\t Rep1\t Rep2\t Rep3\t Mean\t Diff\n');
            for j= 1:numConds;
                fprintf(' --> %5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\n', Inducing_bg_lum(j), Matched_lum(j,1:numReps), mean(Matched_lum(j,1:numReps)),diffTargMatch(j));
            end;
            fprintf(' --> Mean Luminance Reduction = %5.2f%%\n',avgLumRed);
            fprintf('--------------------------------------------------\n\n');
            save(strcat(initials,'_',int2str(tme(2)),'_',int2str(tme(3))));
        end;
        fclose(fid);
    end;
    Screen('CloseAll');
    ListenChar(1);
    ShowCursor;

catch
    s = lasterror;
    ddd = psychlasterror;
    msg = ddd.message
    ListenChar(1);
    ShowCursor;
    ddd = lasterror;
    ddd.message
    ddd.stack(1,1).line
    psychrethrow(lasterror);

    Screen('CloseAll');
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    Priority(0);

    psychrethrow(psychlasterror);
end %try..catch..
