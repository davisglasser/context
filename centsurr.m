function [avg_thresh] = centsurr(initials, scale_factor, frame_rate, linearize, Trials, out_contrast, start)
ListenChar(2);
HideCursor;
try
    %----------Universal Variables----------


    tme = clock;
    frame_rate                      = 120;          % screen frame rate (hz)
    duration                        = 200;          % ms
    ITI                             = 250;          % ms


    %----------Grating----------
    in_stimulus_radius              = 60;      % in arcmin
    out_stimulus_radius             = 300;  %originally 360
    buffer                          = 0;
    contrastL                       = [25 25];
    contrastR                       = [25 25];
    angle                           = 0;
    SF                              = 1;      % c/deg
    TF                              = 4;      % Temporal frequency Hz

    background                      = 126;      % background intensity, in gray scale units


    %---------Staircase stuff----------
    steps                               = [.13 .06 .025];  % increment values, in log percent
    step_pos                            = [1 1];        % what step are we using? incremented after 2 flips
    flips                               = [0 0];        % number of flips.
    flipped                             = 0;        %was the last trial a flip?
    proceed                             = [1 1];
    trial                               = 1;
    cond_count                          = [1 1];

    %----------Housekeeping Stuff----------
    if ~out_contrast
        out_stimulus_radius  = in_stimulus_radius;
    end


    out_stimulus_radius  = round(out_stimulus_radius /scale_factor);
    in_stimulus_radius  = round(in_stimulus_radius /scale_factor);
    f=(SF*scale_factor/60)*2*pi;
    TFstep = (2*pi*TF)/frame_rate;
    mv_length = round((2*pi)/TFstep);
    frames = duration/(1000/frame_rate);

    OpenScreensCalib;

    Screen('DrawText', w, 'Please Wait...', 100, 100, 0);
    Screen('Flip', w);

    angle=angle*pi/180;
    a=cos(angle)*f; b=sin(angle)*f;

    %----------Spatial Envelope----------
    % make the inner spatial envelope
    [in_x,in_y]=meshgrid(-out_stimulus_radius:out_stimulus_radius,-out_stimulus_radius:out_stimulus_radius);
    in_bps = (out_stimulus_radius)*2+1;
    in_circle=((in_stimulus_radius)^2-(in_x.^2+in_y.^2));
    for i=1:in_bps; for j =1:in_bps; if in_circle(i,j) < 0; in_circle(i,j) = 0; else in_circle(i,j) = 1; end; end;
    end;

    % make buffer spatial envelope
    [buf_x,buf_y]=meshgrid(-(out_stimulus_radius):out_stimulus_radius,-(out_stimulus_radius):out_stimulus_radius);
    buf_bps = (out_stimulus_radius)*2+1;
    buf_circle=((in_stimulus_radius+buffer)^2-(buf_x.^2+buf_y.^2));
    for i=1:buf_bps; for j =1:buf_bps; if buf_circle(i,j) < 0; buf_circle(i,j) = 0; else buf_circle(i,j) = 1; end; end;
    end;

    % make the outter spatial envelope
    [out_x,out_y]=meshgrid(-out_stimulus_radius:out_stimulus_radius,-out_stimulus_radius:out_stimulus_radius);
    out_bps = (out_stimulus_radius)*2+1;
    out_circle=((out_stimulus_radius)^2-(out_x.^2+out_y.^2));
    for i=1:out_bps; for j =1:out_bps; if out_circle(i,j) < 0; out_circle(i,j) = 0; else out_circle(i,j) = 1; end; end;
    end;
    out_circle = out_circle-buf_circle;


    %----------Stimulus Rectangles----------
    movie_rect= [0,0,out_bps,out_bps];
    scr_left_middle = fix(screen_rect(3)/2)-round(out_bps/2);
    scr_top = fix(screen_rect(4)/2)-round(out_bps/2);
    screen_rect_middle = movie_rect + [scr_left_middle, scr_top, scr_left_middle, scr_top];



    %----------Randomize trial order----------
    perm = randperm(1000);
    perm = mod(perm,2)+1;

    %----------Initialize Staircases----------
    staircase1(1,1) = contrastL(1);
    staircase1(1,2) = contrastR(1);
    staircase2(1,1) = contrastL(2);
    staircase2(1,2) = contrastR(2);



    %instructions
    %----------Calculate Grating Motion----------
    motion_stepL(1) = rand*2*pi;  motion_stepR(1) = rand*2*pi; motion_stepSurr(1) = rand*2*pi;
    for i=2:mv_length;
        motion_stepL(i) = motion_stepL(i-1)+TFstep; motion_stepR(i) = motion_stepR(i-1)-TFstep;
        motion_stepSurr(i) = motion_stepSurr(i-1)-TFstep;
    end
    %----------Make the Movie-----------
    for i = 1:(mv_length);
        moving_grattingL =round((sin(a*in_x+b*in_y+ motion_stepL(i)).*in_circle*contrastL(1)*background/100));
        moving_grattingR =round((sin(a*in_x+b*in_y+ motion_stepR(i)).*in_circle*contrastR(1)*background/100));
        moving_grattingSurr =round((sin(a*out_x+b*out_y+ motion_stepSurr(i)).*out_circle*(out_contrast)*background/100));
        moving_gratting = moving_grattingL+moving_grattingR+moving_grattingSurr+background;
        movie(i) = Screen('MakeTexture',w,moving_gratting);
    end

    frame = 1;     FRAMESd = round(frames*1.5);
    FlushEvents('keyDown');
    validKey = 0;
    while ~validKey
        Screen('DrawText', w, 'Task: what is the motion direction of the center circle: LEFT or RIGHT?',sr_hor-3*sr_hor/4,40,[255 0 0]);
        Screen('DrawText', w, 'Answer by pressing either the LEFT or the RIGHT arrow key',sr_hor-3*sr_hor/4,100,0);
        Screen('DrawText', w, '(Press the UP arrow to begin)',sr_hor-3*sr_hor/4,150,0);
        Screen('DrawText', w, 'Initiate EACH trial with the UP arrow',sr_hor-3*sr_hor/4,200,0);
        Screen('DrawText', w, '**** Do not rush **** Guess if unsure ****',sr_hor-3*sr_hor/4,250,[255 0 0]);
        if Trials<25
            Screen('DrawText', w, '*** PRACTICE ***',sr_hor-3*sr_hor/4+100,screen_rect(4)-100,[255 0 0]);
        end

        Screen('DrawTexture', w, movie(mod(frame,mv_length)+1),[],screen_rect_middle+[0 100 0 100]);
        Screen('Flip',w);
        [keyIsDown,timeSecs,keyCode] = KbCheck;
        if keyIsDown;
            if keyCode(82)
                validKey = 1;
            end;
        end;
        frame = frame +1;
        if frame == FRAMESd
            frame = 1;
            Screen('FillRect',w, background);
            Screen('DrawText', w, 'Task: what is the motion direction of the center circle: LEFT or RIGHT?',sr_hor-3*sr_hor/4,40,[255 0 0]);
            Screen('DrawText', w, 'Answer by pressing either the LEFT or the RIGHT arrow key',sr_hor-3*sr_hor/4,100,0);
            Screen('DrawText', w, '(Press the UP arrow to begin)',sr_hor-3*sr_hor/4,150,0);
            Screen('DrawText', w, 'Initiate EACH trial with the UP arrow',sr_hor-3*sr_hor/4,200,0);
            Screen('DrawText', w, '**** Do not rush **** Guess if unsure ****',sr_hor-3*sr_hor/4,250,[255 0 0]);
            if Trials<25
                Screen('DrawText', w, '*** PRACTICE ***',sr_hor-3*sr_hor/4+100,screen_rect(4)-100,[255 0 0]);
            end
            Screen('Flip',w);
            waitsecs(.5);
        end
    end
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

    in_grating = a*in_x+b*in_y;
    out_grating = a*out_x+b*out_y;
    % MAIN LOOP
    while (mean(proceed)>0) && (trial < Trials)
        aa = GetSecs;
        if perm(trial)==1
            if proceed(1)
                contrastL = staircase1(cond_count(1),1);
                contrastR = staircase1(cond_count(1),2);
                condition = 1;
            else
                contrastL = staircase2(cond_count(2),1);
                contrastR = staircase2(cond_count(2),2);
                condition = 2;
            end
        else
            if proceed(2)
                contrastL = staircase2(cond_count(2),1);
                contrastR = staircase2(cond_count(2),2);
                condition = 2;
            else
                contrastL = staircase1(cond_count(1),1);
                contrastR = staircase1(cond_count(1),2);
                condition = 1;
            end
        end
        cond_count(condition) = cond_count(condition)+1;
        %end staircase boilerplate

        %----------Set New Amplitudes----------
        amplitudeL = contrastL*background/100;
        amplitudeR = contrastR*background/100;
        amplitudeSurr = out_contrast*background/100;

        %----------Calculate Grating Motion----------
        motion_stepL(1) = rand*2*pi;
        motion_stepR(1) = rand*2*pi;
        motion_stepSurr(1) = rand*2*pi;
        for i=2:mv_length;
            motion_stepL(i) = motion_stepL(i-1)+TFstep;
            motion_stepR(i) = motion_stepR(i-1)-TFstep;
            if condition==1
                motion_stepSurr(i) = motion_stepSurr(i-1)-TFstep;
            else
                motion_stepSurr(i) = motion_stepSurr(i-1)+TFstep;
            end
        end
        if (amplitudeL+amplitudeR)>background
            over = (amplitudeL+amplitudeR)-background;
            if amplitudeL>amplitudeR
                amplitudeL = amplitudeL-over;
            else
                amplitudeR = amplitudeR-over;
            end
        end

        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
        %----------Make the Movie-----------
        for i = 1:mv_length;
            moving_grattingL =sin(in_grating + motion_stepL(i)).*in_circle*amplitudeL;
            moving_grattingR =sin(in_grating + motion_stepR(i)).*in_circle*amplitudeR;
            moving_grattingSurr =sin(out_grating + motion_stepSurr(i)).*out_circle*amplitudeSurr;
            moving_gratting = round(moving_grattingL+moving_grattingR+moving_grattingSurr+background);
            movie(i) = Screen('MakeTexture',w,moving_gratting);
        end

        Priority(0);

        % draw the black fixation cross
        Screen(w,'DrawLine',0,sr_hor-6,sr_ver,sr_hor+6,sr_ver,3);
        Screen(w,'DrawLine',0,sr_hor,sr_ver-6,sr_hor,sr_ver+6,3);
        Screen('Flip',w);
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

        WaitSecs(0.5);



        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
        % play the movie
        for ii=1:frames
            Screen('DrawTexture', w, movie(mod(ii,mv_length)+1));
            Screen('Flip',w);
        end
        Screen('FillRect',w, background); Screen('Flip', w);
        Priority(0);
        FlushEvents('keyDown');
        validKey = 0;
        frame = 0;
        while ~validKey
            [keyIsDown,timeSecs,keyCode] = KbCheck;
            if keyIsDown;
                if keyCode(80)||keyCode(79)
                    validKey = 1;
                end
            end
        end

        if keyCode(80)
            resp = 1;
        else
            resp = 2;
        end

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
                flips1(flips(1)) = staircase1(cond_count(1)-1,1)./staircase1(cond_count(1)-1,2);
            else
                flips2(flips(2)) = staircase2(cond_count(2)-1,1)./staircase2(cond_count(2)-1,2);
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
                staircase1(cond_count(1),1) = 10^(log10(staircase1(cond_count(1)-1,1))-steps(step_pos(condition)));
                staircase1(cond_count(1),2) = 10^(log10(staircase1(cond_count(1)-1,2))+steps(step_pos(condition)));
            else
                staircase1(cond_count(1),1) = 10^(log10(staircase1(cond_count(1)-1,1))+steps(step_pos(condition)));
                staircase1(cond_count(1),2) = 10^(log10(staircase1(cond_count(1)-1,2))-steps(step_pos(condition)));
            end
        else
            if resp == 1
                staircase2(cond_count(2),1) = 10^(log10(staircase2(cond_count(2)-1,1))-steps(step_pos(condition)));
                staircase2(cond_count(2),2) = 10^(log10(staircase2(cond_count(2)-1,2))+steps(step_pos(condition)));
            else
                staircase2(cond_count(2),1) = 10^(log10(staircase2(cond_count(2)-1,1))+steps(step_pos(condition)));
                staircase2(cond_count(2),2) = 10^(log10(staircase2(cond_count(2)-1,2))-steps(step_pos(condition)));
            end
        end
        last_resp(condition) = resp;
        trial = trial+1;
    end
    if Trials>999
        thresh1 = mean(flips1(flips(1)-3:flips(1)));
        thresh2 = mean(flips2(flips(2)-3:flips(2)));

        y1 = log10(thresh1)/2;
        y2 = log10(thresh2)/2;

        C1 = 10^(log10(30)+y1);
        C2 = 10^(log10(30)+y2);

        effect_size = abs(log10(C2)-log10(C1))/2;

        fid = fopen(strcat(initials,'_',int2str(tme(2)),'_',int2str(tme(3))),'a');
        fprintf(fid,'--------------------------------------------------\n');
        fprintf(fid,'%s\t%02.0f/%02.0f/%4.0f\t%02.0f:%02.0f\n',initials,tme(2),tme(3),tme(1),tme(4),tme(5));
        fprintf(fid,'Counterphase Center Surround Illusion\n');
        fprintf(fid,' --> Stair 1 Mean = %5.2f \n',thresh1);
        fprintf(fid,' --> Stair 2 Mean = %5.2f \n',thresh2);
        fprintf(fid,' --> Effect size  = %5.3f \n',effect_size);
        fprintf(fid,'--------------------------------------------------\n\n');
        fclose(fid);
        fprintf('--------------------------------------------------\n');
        fprintf('%s\t%02.0f/%02.0f/%4.0f\t%02.0f:%02.0f\n',initials,tme(2),tme(3),tme(1),tme(4),tme(5));
        fprintf('Counterphase Center Surround Illlusion\n');
        fprintf(' --> Stair 1 Mean = %5.2f \n',thresh1);
        fprintf(' --> Stair 2 Mean = %5.2f \n',thresh2);
        fprintf(' --> Effect size  = %5.3f \n',effect_size);
        fprintf('--------------------------------------------------\n\n');
    else
        avg_thresh = start;
    end
    Screen('CloseAll');
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    ListenChar(1);
    ShowCursor;
    Screen('CloseAll');

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


