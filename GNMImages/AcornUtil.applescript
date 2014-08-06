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
end script