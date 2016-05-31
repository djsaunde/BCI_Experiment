% Script to get participant information and call set up GUI
% Dan Saunders
% 23 May 2016

userNum = 0;
quitApp = 0;

while sum(isstrprop(userNum,'digit'))~=3
    userNum = custom_inputdlg('Please enter a 3-digit subject code:');
    try
        userNum = userNum{1};
    catch
        quitApp = 1;
        break
    end
end

if quitApp ~= 1
    choiceList = {'Train 1', 'Train 2', 'Train 3', 'Test'};
    choice = custom_menu('Please Choose a Mode', choiceList);
    
    if choice ~= 0
        % Check to see if file exists
        currDir = mfilename('fullpath');
        dirName = '';
        while ~strcmp(dirName,'Code')
            [currDir,dirName,~] = fileparts(currDir);
        end
        filepath = fullfile(currDir,'Data');
        if ~exist(filepath,'dir')
            mkdir(filepath);
        end
        if exist(fullfile(filepath,[num2str(userNum) '_' choiceList{choice} '.txt']),'file');
            difficult_choice = custom_menu({'Participant file already exists.', 'Would you like to overwrite it?','WARNING: This cannot be undone.'},{'Yes','Cancel'});
            if difficult_choice == 0 || difficult_choice ==  2 % if cancel
                choice = 0; % Quit
            end
        end

        if choice
            BCI_GUI(choiceList{choice},userNum);
        end
    end
end