function [avg_thresh] = orientation(initials, scale_factor, frame_rate, linearize, Trials, out_contrast, start)
ListenChar(2);
HideCursor;
try

    % CHANGE DEG TO RADIANS
    %----------Universal Variables----------
    tme = clock;
    background                      = 126;      % background intensity, in gray scale units
    ITI                             = 500;      % in ms
    %----------Outer Grating----------
    out_stimulus_radius             = 240;      % in arcmin
    out_angle                       = -15;        % in degress, 0 = vertical
    out_SF                          = 3;        % c/deg
    %----------Inner Grating----------
    in_stimulus_radius              = 30;      % in arcmin
    in_contrast                    	= 50;
    in_angle_start                  = [-(rand)*11 (rand)*11];        % in degress, 0 = horizontal motion
    in_SF                           = 3;        % c/deg
    buffer                          = 0;        % Gap between inner and outer gratings (arcmin)

    steps                               = [3.5 1.2 .5];  % increment values, # and values can be changed to any number
    step_pos                            = [1 1];        % what step are we using? incremented after 2 flips
    flips                               = [0 0];        % number of flips.
    flipped                             = 0;        %was the last trial a flip?
    proceed                             = [1 1];
    trial                               = 1;
    cond_count                          = [1 1];


    %---------------------------------------
    % housekeeping stuff
    out_stimulus_radius  = round(out_stimulus_radius /scale_factor);
    in_stimulus_radius  = round(in_stimulus_radius /scale_factor);
    out_f=(out_SF*scale_factor/60)*2*pi;
    in_f=(in_SF*scale_factor/60)*2*pi;
    out_angle=out_angle*pi/180;
    in_angle_start = in_angle_start*pi/180;
    out_a=cos(out_angle)*out_f; out_b=sin(out_angle)*out_f;
    out_amplitude = background*out_contrast/100;
    in_amplitude = background*in_contrast/100;
    steps = steps*pi/180;


    OpenScreensCalib;

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

    %  create stimulus rectangles
    movie_rect= [0,0,out_bps,out_bps];
    scr_left_middle = fix(screen_rect(3)/2)-round(out_bps/2);
    scr_top = fix(screen_rect(4)/2)-round(out_bps/2);
    screen_rect_middle = movie_rect + [scr_left_middle, scr_top, scr_left_middle, scr_top];
    screen_patch = screen_rect_middle;



    %----------randomize trial order----------
    perm = randperm(1000);
    perm = mod(perm,2)+1;

    staircase1(1) = in_angle_start(1);
    staircase2(1) = in_angle_start(2);

    tic;
    % draw the white fixation cross
    Screen('DrawLine',w,200,sr_hor-2,sr_ver,sr_hor+2,sr_ver,2);
    Screen('DrawLine',w,200,sr_hor,sr_ver-2,sr_hor,sr_ver+2,2);

    %instructions
    Screen('DrawText', w, 'Task: Is the center circle tilted to the LEFT or to the RIGHT?',sr_hor-3*sr_hor/4,40,[255 0 0]);
    Screen('DrawText', w, 'Answer by pressing either the LEFT or the RIGHT arrow key',sr_hor-3*sr_hor/4,100,0);
    Screen('DrawText', w, '(Press the UP arrow to begin)',sr_hor-3*sr_hor/4,150,0);
    Screen('DrawText', w, '**** Do not rush **** Guess if unsure ****',sr_hor-3*sr_hor/4,200,[255 0 0]);
    if Trials<25
        Screen('DrawText', w, '*** PRACTICE ***',sr_hor-3*sr_hor/4+100,screen_rect(4)-100,[255 0 0]);
    end
    in_a=cos(in_angle_start(1))*in_f; in_b=sin(in_angle_start(1))*in_f;
    moving_gratting =round(((sin(out_a*out_x+out_b*out_y+rand*2*pi).*out_circle*out_amplitude)+(sin(in_a*in_x+in_b*in_y+ rand*2*pi).*in_circle*in_amplitude)+background));
    movie = Screen('MakeTexture',w,moving_gratting);
    Screen('DrawTexture', w, movie);
    Screen('FrameOval', w,0,CenterRect([0 0 in_stimulus_radius*2 in_stimulus_radius*2],screen_rect));
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
    Screen('FillRect',w, background);
    Screen('Flip', w);


    % MAIN LOOP
    while mean(proceed)>0  && (trial < Trials)
        if perm(trial)==1
            if proceed(1)
                in_angle_abs = staircase1(cond_count(1));
                condition = 1;
                cond_count(condition) = cond_count(condition)+1;
            else
                in_angle_abs = staircase2(cond_count(2));
                condition = 2;
                cond_count(condition) = cond_count(condition)+1;
            end
        else
            if proceed(2)
                in_angle_abs = staircase2(cond_count(2));
                condition = 2;
                cond_count(condition) = cond_count(condition)+1;
            else
                in_angle_abs = staircase1(cond_count(1));
                condition = 1;
                cond_count(condition) = cond_count(condition)+1;
            end
        end
        %end staircase boilerplate
        
        if condition==1
            in_angle = in_angle_abs;
            out_angleS = out_angle;
        else
            in_angle = in_angle_abs;
             out_angleS = -out_angle;
        end
        % draw the black fixation cross
        Screen('DrawLine',w,0,sr_hor-2,sr_ver,sr_hor+2,sr_ver,2);
        Screen('DrawLine',w,0,sr_hor,sr_ver-2,sr_hor,sr_ver+2,2);
        Screen('Flip',w);

        % calculate the grating position
        out_motion_step = rand*2*pi;
        in_motion_step = rand*2*pi;

        % make the movie
        in_a=cos(in_angle)*in_f; in_b=sin(in_angle)*in_f;
            out_a=cos(out_angleS)*out_f; out_b=sin(out_angleS)*out_f;
        moving_gratting =round(((sin(out_a*out_x+out_b*out_y+out_motion_step).*out_circle*out_amplitude)+(sin(in_a*in_x+in_b*in_y+ in_motion_step).*in_circle*in_amplitude)+background));
        movie = Screen('MakeTexture',w,moving_gratting);
        FlushEvents('keyDown');
        %         validKey = 0;
        %         while ~validKey
        %             theKey = GetChar;
        %             if theKey == '0'
        %                 validKey = 1;
        %             end
        %         end

        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
        % play the movie
        Screen('DrawTexture', w, movie);
        Screen('FrameOval', w,0,CenterRect([0 0 in_stimulus_radius*2 in_stimulus_radius*2],screen_rect));


        Screen('Flip',w);



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
        Priority(0);

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

        % update the values
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

        thresh1 = mean(flips1(flips(1)-3:flips(1)))*180/pi;
        thresh2 = mean(flips2(flips(2)-3:flips(2)))*180/pi;
        avg_thresh = (thresh1+thresh2)/2;

        fid = fopen(strcat(initials,'_',int2str(tme(2)),'_',int2str(tme(3))),'a');
        fprintf(fid,'--------------------------------------------------\n');
        fprintf(fid,'%s\t%02.0f/%02.0f/%4.0f\t%02.0f:%02.0f\n',initials,tme(2),tme(3),tme(1),tme(4),tme(5));
        fprintf(fid,'Tilt Surround Illusion\n');
        fprintf(fid,' -->  Stair 1 Mean = %5.2f degrees \n',thresh1);
        fprintf(fid,' -->  Stair 2 Mean = %5.2f degrees \n',thresh2);
        fprintf(fid,' -->  Effect size  = %5.2f degrees\n',abs(thresh2-thresh1)/2);
        fprintf(fid,'--------------------------------------------------\n\n');
        fclose(fid);
        fprintf('--------------------------------------------------\n');
        fprintf('%s\t%02.0f/%02.0f/%4.0f\t%02.0f:%02.0f\n',initials,tme(2),tme(3),tme(1),tme(4),tme(5));
        fprintf('Tilt Surround Illlusion\n');
        fprintf(' -->  Stair 1 Mean = %5.2f degrees \n',thresh1);
        fprintf(' -->  Stair 2 Mean = %5.2f degrees \n',thresh2);
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
    screen('CloseAll');
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    ListenChar(1);
catch
    ShowCursor
    ListenChar(1);
    ddd = lasterror;
    ddd.message
    ddd.stack(1,1).line
    psychrethrow(lasterror);

    Screen('CloseAll');
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    Priority(0);
end %try..catch..