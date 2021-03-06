#!/usr/bin/osascript

# version 3

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

    end repeat

end tell

on MIC_SWITCH(status)
    if status = true then
        do shell script "curl http://10.0.4.30/MIC_ON --connect-timeout 2"
    else
        do shell script "curl http://10.0.4.30/MIC_OFF --connect-timeout 2"
    end if
end MIC_SWITCH

on CAM_SWITCH(status) 
    if status = true then
        do shell script "curl http://10.0.4.30/CAM_ON --connect-timeout 2"
    else
        do shell script "curl http://10.0.4.30/CAM_OFF --connect-timeout 2"
    end if
end CAM_SWITCH

on AIR_SWITCH(status)
    if status = true then
        do shell script "curl http://10.0.4.30/AIR_ON --connect-timeout 2"
    else
        do shell script "curl http://10.0.4.30/AIR_OFF --connect-timeout 2"
    end if
end AIR_SWITCH




