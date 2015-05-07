function [avg_thresh] = motion(initials, scale_factor, frame_rate, linearize, Trials, out_contrast, start)
ListenChar(2);
HideCursor;
try
    %----------Universal Variables----------
    %out_contrast =80;
    tme = clock;
    frame_rate                      = 120;       % screen frame rate (hz)
    duration                        = 200;      % Movie length in ms
    background                      = 126;      % background intensity, in gray scale units

    ITI                             = 500;
    %----------Rings----------
    out_stimulus_radius             = 360;      % in arcmin
    in_stimulus_radius              = 60;      % in arcmin
    in_contrast                    	= 80;
    buffer                          = 0;        % Gap between inner and outer gratings (arcmin)
    speed                           = 3;       %deg/s
    %---------Staircase stuff----------
    steps                               = [9 4 2];  % increment values, # and values can be changed to any number
    step_pos                            = [1 1];        % what step are we using? incremented after 2 flips
    flips                               = [0 0];        % number of flips.
    flipped                             = 0;        %was the last trial a flip?
    proceed                             = [1 1];
    trial                               = 1;
    cond_count                          = [1 1];
    %---------Response bar---------
    %thickness = 8;
    angle_start = [-(rand)*18 (rand)*18];
    bar_length = out_stimulus_radius;

    fliterYN = 1;
    B = fir1(40,.1);
    h = ftrans2(B);


    % housekeeping stuff
    out_stimulus_radius  = round(out_stimulus_radius /scale_factor);
    in_stimulus_radius  = round(in_stimulus_radius /scale_factor);
    out_amplitude = background*out_contrast/100;
    in_amplitude = background*in_contrast/100;
    mv_lengthM = duration*frame_rate/1000;
    mv_length = 3*duration*frame_rate/1000;
    offset = speed*60/scale_factor/frame_rate;
    angle_start = angle_start*pi/180;
    bar_length = bar_length/scale_factor;


    OpenScreensCalib;

    Screen('DrawText', w, 'Please Wait...', 100, 100, 0);
    Screen('Flip', w);

    steps = steps*pi/180;

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
    out_bps = floor((out_stimulus_radius)*2+1);
    out_circle=((out_stimulus_radius)^2-(out_x.^2+out_y.^2));
    for i=1:out_bps; for j =1:out_bps; if out_circle(i,j) < 0; out_circle(i,j) = 0; else out_circle(i,j) = 1; end; end;
    end;
    out_circle = out_circle-buf_circle;

    %  create stimulus rectangles
    movie_rect= [0,0,out_bps,out_bps];
    scr_left_middle = fix(screen_rect(3)/2)-round(out_bps/2);
    scr_top = fix(screen_rect(4)/2)-round(out_bps/2);
    screen_rect_middle = movie_rect + [scr_left_middle, scr_top, scr_left_middle, scr_top];
    screen_patch = screen_rect_middle;



    %----------Create motion stimuli before the trials begin---------

    travel = offset*(mv_length+5);
    offset_out = offset;
    offset_in = offset/sqrt(2);
    out_source = (round(rand(round(out_bps),round(out_bps+travel)))*2-1);%create this, then resample by 3 or so, size =out_bps+travel square(rc)
    out_source = imresize(out_source,3,'nearest');
    in_source = (round(rand(round(out_bps),round(out_bps+travel)))*2-1);%create this, then resample by 3 or so, size =out_bps+travel square(rc)
    in_source = imresize(in_source,3,'nearest');
    if fliterYN
        out_source = filter2(h, out_source);
        in_source = filter2(h, in_source);
        out_source = out_source/(max(max(abs(out_source))));
        in_source = in_source/(max(max(abs(in_source))));
    end

    mtp = 1;
    for i=1:mv_length
        %frame = out_source((1+(i-1)*offset):((i-1)*offset)+out_bps,(1+(i-1)*offset):((i-1)*offset)+out_bps).*out_circle*out_amplitude+in_source(1:out_bps,(1+(i-1)*offset):((i-1)*offset)+out_bps).*in_circle*in_amplitude+background;
        frame = out_source(1:out_bps,(1+round((i-1)*offset_out*mtp)):(round((i-1)*offset_out*mtp))+out_bps).*out_circle*out_amplitude+in_source((1+round((i-1)*offset_in)):(round((i-1)*offset_in))+out_bps,(1+round((i-1)*offset_in)):(round((i-1)*offset_in))+out_bps).*in_circle*in_amplitude+background;
        movie1(i) = Screen('MakeTexture',w,frame);
    end
    for i=1:mv_length
        %frame = out_source((1+(i-1)*offset):((i-1)*offset)+out_bps,(1+(i-1)*offset):((i-1)*offset)+out_bps).*out_circle*out_amplitude+in_source(1:out_bps,(1+(i-1)*offset):((i-1)*offset)+out_bps).*in_circle*in_amplitude+background;
        frame = out_source(1:out_bps,(1+round((i-1)*offset_out*mtp)):(round((i-1)*offset_out*mtp))+out_bps).*out_circle*out_amplitude+in_source((1+round((mv_length-i)*offset_in)):(round((mv_length-i)*offset_in))+out_bps,(1+round((i-1)*offset_in)):(round((i-1)*offset_in))+out_bps).*in_circle*in_amplitude+background;
        movie2(i) = Screen('MakeTexture',w,frame);
    end

    %----------randomize trial order----------
    perm = randperm(1000);
    perm = mod(perm,2)+1;

    staircase1(1) = angle_start(1);
    staircase2(1) = angle_start(2);

    Screen(w,'DrawLine',0,sr_hor-2,sr_ver,sr_hor+2,sr_ver,2);
    Screen(w,'DrawLine',0,sr_hor,sr_ver-2,sr_hor,sr_ver+2,2);


    %instructions

    frame = 1;
    FlushEvents('keyDown');
    validKey = 0;
    while ~validKey
        Screen('DrawText', w, 'Task: are the blobs in the center moving UP and LEFT or UP and RIGHT?',100,40,[255 0 0]);
        Screen('DrawText', w, 'Answer by pressing either the LEFT or the RIGHT arrow key',100,100,0);
        Screen('DrawText', w, '(Press the UP arrow to begin)',100,150,0);
        Screen('DrawText', w, 'Initiate EACH trial with the UP arrow',100,200,0);
        Screen('DrawText', w, '**** Do not rush **** Guess if unsure ****',100,250,[255 0 0]);
        if Trials<25
            Screen('DrawText', w, '*** PRACTICE ***',400,screen_rect(4)-100,[255 0 0]);
        end
        Screen('DrawTexture', w, movie1(frame),movie_rect,screen_rect_middle+[0 100 0 100],angle_start(1)*180/pi+45);
        Screen('Flip',w);
        [keyIsDown,timeSecs,keyCode] = KbCheck;
        if keyIsDown;
            if keyCode(82)
                validKey = 1;
            end;
        end;
        frame = frame +1;
        if frame == (mv_length)
            frame = 1;
            Screen('FillRect',w, background);
            Screen('DrawText', w, 'Task: are the blobs in the center moving UP and LEFT or UP and RIGHT?',100,40,[255 0 0]);
            Screen('DrawText', w, 'Answer by pressing either the LEFT or the RIGHT arrow key',100,100,0);
            Screen('DrawText', w, '(Press the UP arrow to begin)',100,150,0);
            Screen('DrawText', w, 'Initiate EACH trial with the UP arrow',100,200,0);
            Screen('DrawText', w, '**** Do not rush **** Guess if unsure ****',100,250,[255 0 0]);
            if Trials<25
                Screen('DrawText', w, '*** PRACTICE ***',400,screen_rect(4)-100,[255 0 0]);
            end
            Screen('Flip',w);
            waitsecs(.3);
        end
    end


    Screen('FillRect',w, background);
    Screen('Flip', w);

    % MAIN LOOP
    while mean(proceed)>0  && (trial < Trials)
        if perm(trial)==1
            if proceed(1)
                angle = staircase1(cond_count(1));
                condition = 1;
                cond_count(condition) = cond_count(condition)+1;
            else
                angle = staircase2(cond_count(2));
                condition = 2;
                cond_count(condition) = cond_count(condition)+1;
            end
        else
            if proceed(2)
                angle = staircase2(cond_count(2));
                condition = 2;
                cond_count(condition) = cond_count(condition)+1;
            else
                angle = staircase1(cond_count(1));
                condition = 1;
                cond_count(condition) = cond_count(condition)+1;
            end
        end
        %end staircase boilerplate

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
        shift = floor(rand*mv_lengthM*2);
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
        %play movie
        if condition==1

            for i=1+shift:mv_lengthM+shift
                Screen('DrawTexture', w, movie1(i),movie_rect,screen_rect_middle,angle*180/pi+45);
                Screen('Flip',w);
            end
        else
            for i=1+shift:mv_lengthM+shift
                Screen('DrawTexture', w, movie2(i),movie_rect,screen_rect_middle,angle*180/pi+135);
                Screen('Flip',w);
            end
        end

        Screen('FillRect',w, background);

        Screen('Flip',w);
        Priority(0);
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
        Screen('Flip',w);

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
                staircase2(cond_count(2)) = staircase2(cond_count(2)-1)+steps(step_pos(condition));
            else
                staircase2(cond_count(2)) = staircase2(cond_count(2)-1)-steps(step_pos(condition));
            end
        end
        last_resp(condition) = resp;
        trial = trial+1;
    end
    if Trials>999
        staircase1 = staircase1*180/pi;
        staircase2 = staircase2*180/pi;
        flips1 = flips1*180/pi;
        flips2 = flips2*180/pi;
        thresh1 = mean(flips1(flips(1)-3:flips(1)));
        thresh2 = mean(flips2(flips(2)-3:flips(2)));
        avg_thresh = (thresh1+thresh2)/2;

        fid = fopen(strcat(initials,'_',int2str(tme(2)),'_',int2str(tme(3))),'a');
        fprintf(fid,'--------------------------------------------------\n');
        fprintf(fid,'%s\t%02.0f/%02.0f/%4.0f\t%02.0f:%02.0f\n',initials,tme(2),tme(3),tme(1),tme(4),tme(5));
        fprintf(fid,'Motion Surround Illusion\n');
        fprintf(fid,' -->  Stair 1 Mean = %5.2f degrees\n',thresh1);
        fprintf(fid,' -->  Stair 2 Mean = %5.2f degrees\n',thresh2);
        fprintf(fid,' -->  Effect size  = %5.2f degrees\n',abs(thresh2-thresh1)/2);
        fprintf(fid,'--------------------------------------------------\n\n');
        fclose(fid);
        fprintf('--------------------------------------------------\n');
        fprintf('%s\t%02.0f/%02.0f/%4.0f\t%02.0f:%02.0f\n',initials,tme(2),tme(3),tme(1),tme(4),tme(5));
        fprintf('Motion Surround Illusion\n');
        fprintf(' -->  Stair 1 Mean = %5.2f degrees\n',thresh1);
        fprintf(' -->  Stair 2 Mean = %5.2f degrees\n',thresh2);
        fprintf(' -->  Effect size  = %5.2f degrees\n',abs(thresh2-thresh1)/2);
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