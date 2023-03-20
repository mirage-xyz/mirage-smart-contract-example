const fs = require('fs');
const path = require('path');

const getLibrariesUsedInContracts = (contractsFolder, nodeModulesFolder) => {
    // Set the contracts and node_modules directory paths
    const contractsDir = path.resolve(__dirname, '..', contractsFolder);
    const nodeModulesDir = path.resolve(__dirname, '..', nodeModulesFolder);

    // Get all .sol files in the contracts directory
    const solFiles = fs.readdirSync(contractsDir).filter(file => file.endsWith('.sol'));

    // Get all folder names inside the node_modules directory
    const nodeModulesFolders = fs.readdirSync(nodeModulesDir, { withFileTypes: true })
        .filter(dirent => dirent.isDirectory())
        .map(dirent => dirent.name);

    // Initialize a Set to store unique import lines
    const uniqueLibraries = new Set();

    // Iterate through each .sol file and process import lines
    solFiles.forEach(file => {
        const filePath = path.join(contractsDir, file);
        const fileContent = fs.readFileSync(filePath, 'utf8');
        
        // Split file content into lines
        const lines = fileContent.split('\n');

        // Filter the lines that start with 'import' and reference a folder in 'node_modules'
        const importLines = lines.filter(line => {

            line = line.trim();
            if (!line.startsWith('import')) {
                return false;
            }
            
            const trimmedLine = line.replace('import ', '').replace('"', '').replace(/\s+/g, '');

            // Extract the prefix before the first '/' or '\' character
            const prefix = trimmedLine.split(/\/|\\/)[0];

            // Check if the prefix matches any folder name in 'node_modules'
            return nodeModulesFolders.includes(prefix);
        });
        
        libraryNames = importLines.map(line => line.replace('import ', '').replace('"', '').replace(/\s+/g, '').split(/\/|\\/)[0]);
        
        // Add each import line to the Set after removing spaces
        libraryNames.forEach(line => {
            uniqueLibraries.add(line);
        });
    });

    // Return the unique imports
    return uniqueLibraries;
};

module.exports = {
    getLibrariesUsedInContracts
};