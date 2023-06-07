function encodding(path_folder,option)
    switch(option)
        case 'Folder'
            encode_folder(path_folder);
        case 'File'
            path_mapping=[path_folder,'\','Subject_encoding.csv'];
            encode_file(path_folder,path_mapping);
    end
end
function encode_folder(path_folder)
    % Initialize lookup table
    encoding = struct('name', {}, 'id', {});
    nextID = 1;

    % Get a list of all subfolders in the specified folder
    subfolders = dir(path_folder);
    subfolders = subfolders([subfolders(:).isdir] & ~ismember({subfolders(:).name}, {'.', '..'}));

    % Loop over each subfolder and encode the name subject
    for i = 1:length(subfolders)
        subfolder = subfolders(i);
        folderName = subfolder.name;
        
        % Extract the name subject from the folder name
        exp1='^FCS_(?<name>[A-Za-z]+)_([M])(?<age>\d+)$';
        exp2='^FCS_Subject (?<name>\d+)_([F][M])(?<age>\d+)$';
        tokens = regexp(folderName, exp1, 'names');
        if isempty(tokens)
            tokens=regexp(folderName,exp2, 'names'); 
            if isempty(tokens)
                continue% Skip folders that do not match the expected pattern
            end
        end
        
        name = tokens.name;
        
        % Check if the name subject has already been encoded
        index = find(strcmp({encoding.name}, name), 1);
        if isempty(index)
            % If the name subject has not been encoded, add it to the lookup table
            encoding(end+1).name = name;
            encoding(end).id = nextID;
            nextID = nextID + 1;
        end
        
        % Encode the name subject in the folder name
        encodedName = sprintf('Subject%03d', encoding(i).id);
        newFolderName = strrep(folderName, name, encodedName);
        oldFolderPath = fullfile(path_folder, folderName);
        newFolderPath = fullfile(path_folder, newFolderName);
        movefile(oldFolderPath, newFolderPath,'f');

    end
    
    % Save the encoding table to a CSV file
    encodingTable = struct2table(encoding);
    writetable(encodingTable, fullfile(path_folder, 'Subject_encoding.csv'));
end
function encode_file(path_folder, path_mapping)
    % Load the encoding table from the specified CSV file
    encodingTable = readtable(path_mapping);
    encoding = struct('name', encodingTable.name, 'id', num2cell(encodingTable.id));
    
    % Get a list of all subfolders in the root folder
    subfolders = dir(path_folder);
    subfolders = subfolders([subfolders(:).isdir] & ~ismember({subfolders(:).name}, {'.', '..'}));

    % Loop over each subfolder and process its files
    for i = 1:length(subfolders)
        subfolder = subfolders(i);
        subfolderPath = fullfile(path_folder, subfolder.name);
        
        % Get a list of all files in the subfolder
        files = dir(fullfile(subfolderPath, '*.txt'));
        
        % Loop over each file and encode the subject name
        for j = 1:length(files)
            file = files(j);
            fileName = file.name;
            % Extract the subject name from the file name
            exp1='^FCS_(?<name>[A-Za-z]+)_[M]\d+_\w+.txt$';
            exp2='^FCS_(?<name>[A-Za-z]+)_[F][M]\d+_\w+.txt$';
            exp3='^E_FCS_(?<name>[A-Za-z]+)_[M]\d+_\w+.txt$';
            exp4='^E_FCS_(?<name>[A-Za-z]+)_[F][M]\d+_\w+.txt$';
            tokens = regexp(fileName, exp1, 'names');
            if isempty(tokens)
                tokens = regexp(fileName, exp2, 'names');
            end

            if isempty(tokens)
                tokens = regexp(fileName, exp3, 'names');
            end

            if isempty(tokens)
                tokens = regexp(fileName, exp4, 'names');
            end

            if isempty(tokens)
                continue % Skip files that do not match any of the expected patterns
            end
            name = tokens.name;
            % Find the subject ID in the encoding table
            index = find(strcmp({encoding.name}, name), 1);
            if isempty(index)
                continue % Skip files for which the subject ID cannot be found in the encoding table
            end

            id = encoding(index).id;

            % Encode the subject name in the file name
            encodedName = sprintf('Subject%03d', id);
            newFileName = strrep(fileName, name, encodedName);
            oldFilePath = fullfile(subfolderPath, fileName);
            newFilePath = fullfile(subfolderPath, newFileName);
            movefile(oldFilePath, newFilePath,'f');
        end
    end
end