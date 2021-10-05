#!/usr/bin/osascript
global AIR_ENABLED
global MIC_ENABLED
global CAM_ENABLED
--global EXIT_FLAG

set AIR_ENABLED to false
set MIC_ENABLED to false
set CAM_ENABLED to false
--set EXIT_FLAG to false

tell application "System Events"
    repeat
        if exists (process "zoom.us") then
            
            tell application process "zoom.us"
                try
                    if exists (menu "會議" of menu bar 1) then
                        
                        my AIR_SWITCH(true)
                        if exists (menu item "音訊靜音" of menu "會議" of menu bar 1) then
                            my MIC_SWITCH(true)
                        else
                            my MIC_SWITCH(false)
                        end if
                        
                        if exists (menu item "停止視訊" of menu "會議" of menu bar 1) then
                            my CAM_SWITCH(true)
                        else
                            my CAM_SWITCH(false)
                        end if
                        
                    else
                        
                        my AIR_SWITCH(false)
                        my MIC_SWITCH(false)
                        my CAM_SWITCH(false)
                        
                    end if
                end try
            end tell
            
        else
            my AIR_SWITCH(false)
            
        end if
        
        
        delay 1
        --if EXIT_FLAG then exit repeat
        
    end repeat
    --continue quit
end tell


--on quit
--    set EXIT_FLAG to true
--continue quit
--end quit


on MIC_SWITCH(status)
    if not MIC_ENABLED = status then
        set MIC_ENABLED to status
        if MIC_ENABLED = true then
            do shell script "curl http://10.0.4.30/MIC_ON --connect-timeout 2"
        else
            do shell script "curl http://10.0.4.30/MIC_OFF --connect-timeout 2"
        end if
    end if
end MIC_SWITCH

on CAM_SWITCH(status)
    if not CAM_ENABLED = status then
        set CAM_ENABLED to status
        if CAM_ENABLED = true then
            do shell script "curl http://10.0.4.30/CAM_ON --connect-timeout 2"
        else
            do shell script "curl http://10.0.4.30/CAM_OFF --connect-timeout 2"
        end if
    end if
end CAM_SWITCH

on AIR_SWITCH(status)
    if not AIR_ENABLED = status then
        set AIR_ENABLED to status
        if AIR_ENABLED = true then
            do shell script "curl http://10.0.4.30/AIR_ON --connect-timeout 2"
        else
            do shell script "curl http://10.0.4.30/AIR_OFF --connect-timeout 2"
        end if
    end if
end AIR_SWITCH




