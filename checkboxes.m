% This function draws heavily from this matlab forum question answer
% https://uk.mathworks.com/matlabcentral/answers/13351-dialog-with-checkboxes-in-gui

function [plotRecoveryYes,averageRecoveryYes,driftYes,plotMasksYes,detailYes] = checkboxes

% Create figure
h.f = figure('units','pixels','position',[200,200,350,150],...
             'toolbar','none','menu','none');
         title('Select options; see readme for details')
         axis off
% position text for information

% Create yes/no checkboxes
% show each individual recovery curve
h.c(1) = uicontrol('style','checkbox','units','pixels',...
                'position',[20,115,350,15],'string','Show individual recovery curves for each image set');

% calculate average recovery curves
h.c(2) = uicontrol('style','checkbox','Value',1,'units','pixels',...
                'position',[20,95,350,15],'string','Calculate an average recovery curve');

% account for drift
h.c(3) = uicontrol('style','checkbox','Value',1,'units','pixels',...
                'position',[20,75,350,15],'string','Account for drift');

% show summary of masks used
h.c(4) = uicontrol('style','checkbox','Value',1,'units','pixels',...
                'position',[20,55,350,15],'string','Show a summary of the masks used and example images');
     
% show details of masks used (all mask)
h.c(5) = uicontrol('style','checkbox','units','pixels',...
                'position',[20,35,350,15],'string','Show every mask used (not recommended)');
            
% Create OK pushbutton   
h.p = uicontrol('style','pushbutton','units','pixels',...
                'position',[125,5,70,20],'string','OK',...
                'callback',@p_call);
% Pushbutton callback
    function p_call(varargin)
        
        % set these options to their value

        plotRecoveryYes = get(h.c(1),'Value'); % check number is 1
        averageRecoveryYes = get(h.c(2),'Value'); % check number is 2
        driftYes = get(h.c(3),'Value'); % check number is 3
        plotMasksYes = get(h.c(4),'Value'); % check number is 4
        detailYes = get(h.c(5),'Value'); % check number is 5
  
        % close the checkbox
        close(gcf)
    end

uiwait(h.f)
end