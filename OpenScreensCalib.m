    %----------Screen Windows----------
  warning('off','MATLAB:dispatcher:InexactMatch')
    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
    screens=Screen('Screens');
    screenNumber=max(screens);
    w=Screen('OpenWindow',screenNumber,0,[],[],2);
    screen_rect = Screen('Rect',w);

    if linearize
        %fid = fopen('MyGammaTable','r');
        %screen_clut = fread(fid,[256 3],'float64');
        %fclose(fid);
        %screen_clut =   screen_clut -1;
        %screen_clut = screen_clut/255;
        load 'linearizedCLUT_082008';
        screen('LoadNormalizedGammaTable',screenNumber,linearizedCLUT);
    end
        Screen('FillRect',w, background);
    Screen('Flip', w);
    Screen('FillRect',w, background);
    Screen('TextSize',w,35);
    Screen('TextFont',w,'Helvetica');
        Screen('TextStyle',w,1);
        sr_hor = round(screen_rect(3)/2);
    sr_ver = round(screen_rect(4)/2);