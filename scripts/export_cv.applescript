on run argv
    set sourcePath to item 1 of argv
    set outputPath to item 2 of argv
    with timeout of 90 seconds
        tell application "Pages Creator Studio"
            activate
            set cvDocument to open POSIX file sourcePath
            if cvDocument is missing value then error "The CV did not finish opening in Pages."
            export cvDocument to POSIX file outputPath as PDF
            close cvDocument saving no
        end tell
    end timeout
end run
