function [avg_thresh] = sizeE(initials, scale_factor, frame_rate, linearize, Trials, out_contrast, start)
ListenChar(2);
HideCursor;
try
    %----------Universal Variables----------

    tme = clock;
    background                          = 128;      % background intensity, in gray scale units

    ref_diameter                        = 130;      % arcmin
    test_diameter_start                 = [round(130-20*(rand)) round(130-20*(rand))];% arcmin
    test_diameter_start = [132 132]
    num_crowders                        = 5;
    crowd_diameter                      = 260;       % arcmin
    gap                                 = 45;       % arcmin must be >13ish?
    color                               = 0;
    ITI                                 = 500;      %ms

    steps                               = [5 2 1];  % increment values, # and values can be changed to any number
    step_pos                            = [1 1];        % what step are we using? incremented after 2 flips
    flips                               = [0 0];        % number of flips.
    flipped                             = 0;        %was the last trial a flip?
    proceed                             = [1 1];
    trial                               = 1;
    cond_count                          = [1 1];

    %----------------------------------------------
    % housekeeping stuff
    ref_diameter                        = round(ref_diameter/scale_factor);
    test_diameter_start                 = round(test_diameter_start/scale_factor);
    crowd_diameter                      = round(crowd_diameter/scale_factor);
    gap                                 = round(gap/scale_factor);
    arm                                 = round(ref_diameter/2+crowd_diameter/2+gap);

    OpenScreensCalib;


    %Crowders
    crowd_pos = linspace(0,num_crowders-1,num_crowders)*360/num_crowders;
    crowd_x = cos(crowd_pos/180*pi)*arm;
    crowd_y = sin(crowd_pos/180*pi)*arm;

    %----------randomize trial order----------
    perm = randperm(1000);
    perm = mod(perm,2)+1;

    staircase1(1) = test_diameter_start(1);
    staircase2(1) = test_diameter_start(2);

    x_ref = sr_hor/2;       y_ref = sr_ver;
    x_test = 3*sr_hor/2;    y_test = sr_ver;


    slide = -100;
    %instructions
    Screen('DrawText', w, 'Task: Which center circle is bigger: LEFT or RIGHT?',sr_hor-3*sr_hor/4,40,[255 0 0]);
    Screen('DrawText', w, 'Answer by pressing either the LEFT or the RIGHT arrow key',sr_hor-3*sr_hor/4,100,0);
    Screen('DrawText', w, '(Press the UP arrow to begin)',sr_hor-3*sr_hor/4,150,0);
    Screen('DrawText', w, '**** Do not rush **** Guess if unsure ****',sr_hor-3*sr_hor/4,200,[255 0 0]);
    if Trials<25
        Screen('DrawText', w, '*** PRACTICE ***',sr_hor-3*sr_hor/4+100,screen_rect(4)-100,[255 0 0]);
    end
    Screen('FillOval',w,color,[x_ref-ref_diameter/2 y_ref-slide-ref_diameter/2 x_ref+ref_diameter/2 y_ref-slide+ref_diameter/2]); % center
    for i=1:length(crowd_pos)
        Screen('FillOval',w,out_contrast,[(x_ref+crowd_x(i))-crowd_diameter/2 (y_ref-slide+crowd_y(i))-crowd_diameter/2 (x_ref+crowd_x(i))+crowd_diameter/2 (y_ref-slide+crowd_y(i))+crowd_diameter/2]);
    end
    Screen('FillOval',w,color,[x_test-test_diameter_start(1)/2 y_test-slide-test_diameter_start(1)/2 x_test+test_diameter_start(1)/2 y_test-slide+test_diameter_start(1)/2]);
    Screen('Flip', w);

    FlushEvents('keyDown');
    validKey = 0;
    while ~validKey
        [keyIsDown,timeSecs,keyCode] = KbCheck;
        if keyIsDown;
            if keyCode(82)
                validKey = 1;
            end;
        end;
    end
    Screen('FillRect',w, background);
    Screen('Flip', w);


    % MAIN LOOP
    while mean(proceed)>0  && (trial < Trials)
        if perm(trial)==1
            if proceed(1)
                test_diameter = staircase1(cond_count(1));
                condition = 1;
                cond_count(condition) = cond_count(condition)+1;
            else
                test_diameter = staircase2(cond_count(2));
                condition = 2;
                cond_count(condition) = cond_count(condition)+1;
            end
        else
            if proceed(2)
                test_diameter = staircase2(cond_count(2));
                condition = 2;
                cond_count(condition) = cond_count(condition)+1;
            else
                test_diameter = staircase1(cond_count(1));
                condition = 1;
                cond_count(condition) = cond_count(condition)+1;
            end
        end
        %end staircase boilerplate
        
        if condition==1
            x_ref = sr_hor/2;       y_ref = sr_ver;
            x_test = 3*sr_hor/2;    y_test = sr_ver;
        else
            x_ref = 3*sr_hor/2;     y_ref = sr_ver;
            x_test = sr_hor/2;      y_test = sr_ver;
        end
    
        Screen('FillOval',w,color,[x_ref-ref_diameter/2 y_ref-ref_diameter/2 x_ref+ref_diameter/2 y_ref+ref_diameter/2]); % center
        for i=1:length(crowd_pos)
            Screen('FillOval',w,out_contrast,[(x_ref+crowd_x(i))-crowd_diameter/2 (y_ref+crowd_y(i))-crowd_diameter/2 (x_ref+crowd_x(i))+crowd_diameter/2 (y_ref+crowd_y(i))+crowd_diameter/2]);
        end
        Screen('FillOval',w,color,[x_test-test_diameter/2 y_test-test_diameter/2 x_test+test_diameter/2 y_test+test_diameter/2]);
        Screen('Flip', w);
        % gets the answer
        FlushEvents('keyDown');
        validKey = 0;
        while ~validKey
            [keyIsDown,timeSecs,keyCode] = KbCheck;
            if keyIsDown;
                if keyCode(80)
                    validKey = 1;
                    resp = 1;
                elseif keyCode(79)
                    validKey = 1;
                    resp = 2;
                end;
            end;
        end
        Screen('FillRect',w, background);
        Screen('Flip', w);
        WaitSecs(ITI/1000);
        %staircase code
        % was this trial a flip?-----
        if cond_count(condition)>2
            if last_resp(condition) ~= resp
                flipped = 1;
            else
                flipped = 0;
            end
        end

        % what are you gonna do about it?-----
        if flipped
            flips(condition) = flips(condition)+1;
            if condition==1
                flips1(flips(1)) = staircase1(cond_count(1)-1);
            else
                flips2(flips(2)) = staircase2(cond_count(2)-1);
            end

            if step_pos(condition)==length(steps);
                if flips(condition) == 2*(length(steps)+1);
                    proceed(condition) = 0;
                end
            else
                step_pos(condition) = floor(flips(condition)/2)+1;
            end
        end

        % update the values--sometimes split based on presentation side/tilt variable
        if condition==1
            if resp == 1
                staircase1(cond_count(1)) = staircase1(cond_count(1)-1)+steps(step_pos(condition));
            else
                staircase1(cond_count(1)) = staircase1(cond_count(1)-1)-steps(step_pos(condition));
            end
        else
            if resp == 1
                staircase2(cond_count(2)) = staircase2(cond_count(2)-1)-steps(step_pos(condition));
            else
                staircase2(cond_count(2)) = staircase2(cond_count(2)-1)+steps(step_pos(condition));
            end
        end
        last_resp(condition) = resp;
        trial = trial+1;
    end
    if Trials>999
        staircase1 = staircase1*scale_factor;
        staircase2 = staircase2*scale_factor;
        flips1 = flips1*scale_factor;
        flips2 = flips2*scale_factor;

        thresh1 = mean(flips1(flips(1)-3:flips(1)));
        thresh2 = mean(flips2(flips(2)-3:flips(2)));
        avg_thresh = (thresh1+thresh2)/2;

        fid = fopen(strcat(initials,'_',int2str(tme(2)),'_',int2str(tme(3))),'a');
        fprintf(fid,'--------------------------------------------------\n');
        fprintf(fid,'%s\t%02.0f/%02.0f/%4.0f\t%02.0f:%02.0f\n',initials,tme(2),tme(3),tme(1),tme(4),tme(5));
        fprintf(fid,'Ebbinghaus Illusion, Large Crowders\n');
        fprintf(fid,' --> Stair 1 Mean = %5.2f arcmin\n',thresh1);
        fprintf(fid,' --> Stair 2 Mean = %5.2f arcmin\n',thresh2);
        fprintf(fid,' --> Contrast reduction = %5.1f%%\n',100*(ref_diameter*scale_factor-mean([thresh2 thresh1]))/(ref_diameter*scale_factor));
        fprintf(fid,'--------------------------------------------------\n\n');
        fclose(fid);


        fprintf('--------------------------------------------------\n');
        fprintf('%s\t%02.0f/%02.0f/%4.0f\t%02.0f:%02.0f\n',initials,tme(2),tme(3),tme(1),tme(4),tme(5));
        fprintf('Ebbinghaus Illusion, Large Crowders\n');
        fprintf(' --> Stair 1 Mean = %5.2f arcmin\n',thresh1);
        fprintf(' --> Stair 2 Mean = %5.2f arcmin\n',thresh2);
        fprintf(' --> Contrast reduction = %5.1f%%\n',100*(ref_diameter*scale_factor-mean([thresh2 thresh1]))/(ref_diameter*scale_factor));
        fprintf('--------------------------------------------------\n\n');
    else
        avg_thresh = start;
    end
    Screen('CloseAll');
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
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