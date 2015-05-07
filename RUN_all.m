clear all;close all;startT = getsecs;clc;


% subject parameters
initials            ='ey';
no_context          =0;       % is the "no context" run included, 1=YES, 0=NO
prac_tr             =0;       % how many practice trials, 5 should be good
number_of_runs      =1;       % how many experimental runs. 3 is best, 2 might be OK
centersurr_context  =0;       % if set to non-zero, program adds an additional no-context
                              % at the end of experimental runs


%task_order = [1 2 3 4 5 6]; % 5 tasks: 1:orientation, 2:size, 3:motion, 4:contrast, 5:center-surrm, 6:brightnessMatching
%task_order = [2 3 4 5 6 1];
%task_order = [3 4 5 6 1 2];
%task_order = [4 5 6 1 2 3];
task_order = [5 6 1 2 3 4];
%task_order  = [6 1 2 3 4 5];

% set-up specific parameters (fixed)
scale_factor    =1.4305;  %1.4305 is scale factor for d = 72.4 and resolution 1280*960
linearize       =1;       %whether to linearize the monitor
frame_rate      =120;     %frame_rate


% experiment------------------
start = 100;  % not relevant at this point
for i=1:max(size(task_order))
    switch task_order(i)
        case 1
            if no_context
                orientation(initials, scale_factor, frame_rate, linearize, 1000, 0, start);
            end
            if prac_tr
                orientation(initials, scale_factor, frame_rate, linearize, prac_tr+1, 97, start);
            end
            for j=1:number_of_runs
                orientation(initials, scale_factor, frame_rate, linearize, 1000, 97, start);
                SysBeep(1,0);
            end
            SysBeep(3,0);
        case 2
            if no_context
                sizeE(initials, scale_factor, frame_rate, linearize, 1000, 128, start);
            end
            if prac_tr
                sizeE(initials, scale_factor, frame_rate, linearize, prac_tr+1, 0, start);
            end
            for j=1:number_of_runs
                sizeE(initials, scale_factor, frame_rate, linearize, 1000, 0, start);
                SysBeep(1,0);
            end
            SysBeep(3,0);
        case 3
            if no_context
                motion(initials, scale_factor, frame_rate, linearize, 1000, 0, start);
            end
            if prac_tr
                motion(initials, scale_factor, frame_rate, linearize, prac_tr+1, 80, start);
            end
            for j=1:number_of_runs
                motion(initials, scale_factor, frame_rate, linearize, 1000, 80, start);
                SysBeep(1,0);
            end
            SysBeep(3,0);
        case 4
            if no_context
                contrast(initials, scale_factor, frame_rate, linearize, 1000, 0, start);
            end
            if prac_tr
                contrast(initials, scale_factor, frame_rate, linearize, prac_tr+1, 97, start);
            end
            for j=1:number_of_runs
                contrast(initials, scale_factor, frame_rate, linearize, 1000, 97, start);
                SysBeep(1,0);
            end
            SysBeep(3,0);
        case 5
            if no_context
               centsurr(initials, scale_factor, frame_rate, linearize, 1000, 0, start);
            end
            if prac_tr
               centsurr(initials, scale_factor, frame_rate, linearize, prac_tr+1, 50, start);
            end
            for j=1:number_of_runs
                centsurr(initials, scale_factor, frame_rate, linearize, 1000, 50, start);
                SysBeep(1,0);
            end
            if centersurr_context
                centsurr(initials, scale_factor, frame_rate, linearize, 1000, 0, start);
            end
            SysBeep(3,0);
        case 6
            if no_context
                brightnessMatching(initials, 0, 0);
            end
            if prac_tr
                brightnessMatching(initials, 1, 1);
            end;
            brightnessMatching(initials, 0, 1);
            SysBeep(3,0);
    end
end
total_time = (getsecs-startT)/60;
tme = clock;
fid = fopen(strcat(initials,'_',int2str(tme(2)),'_',int2str(tme(3))),'a');
fprintf(' --> Total time elapssed (min) %5.1f\n',total_time);
fprintf(fid,' --> Total time elapssed (min) %5.1f\n',total_time);
fclose(fid);






