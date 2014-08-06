--
--  AppDelegate.applescript
--  ASTest
--
--  Created by localhome on 04/08/2014.
--  Copyright (c) 2014 Guardian News & Media. All rights reserved.
--

script AcornUtil
	property parent : class "NSObject"
	
	-- IBOutlets
--	property window : missing value
	
--	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
--	end applicationWillFinishLaunching_
	
--	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits
--		return current application's NSTerminateNow
--	end applicationShouldTerminate_

    on test_(sender)
        -- display alert "Hello"
        
        tell application "Acorn"
            taunt
        end tell
    end test_
    
    on filename_(sender)
        tell application "Acorn"
            set theFileName to file of document 1
        end
        return posix path of theFileName
    end
    
    on setFilename_(sender)
    end
    
    on currentFileURL_(sender)
        tell application "Acorn"
            set theFileName to file of document 1
        end
        
        set rtn to "file://" & posix path of theFileName
        return rtn
    end
    
    on currentFileWidth_(sender)
        tell application "Acorn"
            set theWidth to width of document 1
        end
        
        return theWidth
    end
    
    on currentFileHeight_(sender)
        tell application "Acorn"
            set theHeight to height of document 1
        end
        
        return theHeight
    end
    
    on currentFileModified_(sender)
        tell application "Acorn"
            set isModified to modified of document 1
        end
        return isModified
    end
end script