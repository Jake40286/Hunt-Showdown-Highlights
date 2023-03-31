# Create a new FileSystemWatcher object and configure it to monitor the source directory for new .mp4 files
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = "G:\ShadowPlay Highlights\Highlights\Hunt  Showdown"
$watcher.Filter = "*.mp4"
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

# Define a script block to execute when a new file is created
$action = {
    # Get the full path, name, and change type of the new file from the event arguments
    $path = $Event.SourceEventArgs.FullPath
    $name = $Event.SourceEventArgs.Name
    $changeType = $Event.SourceEventArgs.ChangeType

    # Define the target directory to copy the file to
    $targetPath = "G:\ShadowPlay Highlights\Captures\Hunt  Showdown"

    # Check if the change type is "Created"
    if ($changeType -eq "Created") {

        # Start a new background job to copy the file and launch the game once the copy is complete
        $job = Start-Job -ScriptBlock {

            # Get the path, name, and target directory from the outer scope using the $using: variable syntax
            $path = $using:path
            $name = $using:name
            $targetPath = $using:targetPath

            # Get the size of the file and store it in a variable
            $file = Get-Item $path
            $size = $file.Length

            # Wait for 5 seconds to allow the file to finish being written to
            Start-Sleep -Seconds 5

            # Get the new size of the file and compare it to the original size
            $newSize = (Get-Item $path).Length
            if ($newSize -eq $size) {

                # If the new size is the same as the original size, the file is done being written to
                # Copy the file to the target directory
                $message = "Copying $name to $targetPath"
                Write-Host $message
                Write-Output $message
                Copy-Item $path $targetPath

                # Launch the game once the file copy is complete
                Start-Process "G:\SteamLibrary\steamapps\common\Hunt Showdown\binaries\win_x64\hunt.exe"
            }
        }
    }
}

# Register an event handler for the FileSystemWatcher object that executes the $action script block when a new file is created
Register-ObjectEvent $watcher "Created" -Action $action

# Launch the game
# Start-Process "G:\Games\steamapps\common\Hunt Showdown (Test Server)\hunt.exe"
