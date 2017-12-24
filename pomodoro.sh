#! /bin/bash

# Basic Technique (https://en.wikipedia.org/wiki/Pomodoro_Technique)

# 1. Decide on the task to be done.
# 2. Set the pomodoro timer (traditionally to 25 minutes).
# 3. Work on the task.
# 4. End work when the timer rings and put a checkmark on a piece of paper.
# 5. If you have fewer than four checkmarks, take a short break (3–5 minutes),
#    then go to step 2.
# 6. After four pomodoros, take a longer break (15–30 minutes), reset your
#    checkmark count to zero, then go to step 1.

################################################################################
# Create settings variables
################################################################################

settings=$HOME/.config/my-scripts/pomodoro.conf

# Use grep to find line for variable. Extracts everything between first and second ':'
# Trims whitspace from both ends.
# Regex matches start of line excluding whitespace.
# Times are returned in seconds
shortBreak=$(grep -iw '^\s*short break:' $settings | cut -d: -f2 | xargs)
longBreak=$(grep -iw '^\s*long break:' $settings | cut -d: -f2 | xargs)
workPeriod=$(grep -iw '^\s*work period:' $settings | cut -d: -f2 | xargs)
togglApiToken=$(grep -iw '^\s*toggl api token:' $settings | cut -d: -f2 | xargs)

################################################################################
# Run timer
################################################################################

#runTimer=true
#while [ "$runTimer" = true ] ; do
    # Work period
        osascript -e \
        'display notification "Starting work timer.\nWork for 25 minutes" with title "Pomodoro"'
        say "Begin."

        # Start time tracking
            curl -v -u $togglApiToken:api_token \
                    -H "Content-Type: application/json" \
                    -d '{"time_entry":{
                            "description":"EMSP2390 Reading Response 2",
                            "tags":["EMSP2390","writing"],
                            "pid":88939415,
                            "created_with":"curl"
                        }}' \
                    -X POST https://www.toggl.com/api/v8/time_entries/start

        sleep $workPeriod # Sleep 25 minutes
        echo

    # Break period
        osascript -e 'display notification "Take a break" with title "Pomodoro"'
        say "Time to take a break."

        read -p "Press any key to start break" -n 1 -s
        echo

        sleep `expr $shortBreak - 60` # Sleep for short break minus one minute for warning time
        osascript -e 'display notification "Break ends in 1 minute" with title "Pomodoro"'
        say "One minute warning."
        sleep 60

        # Start time tracking
            curl -v -u $togglApiToken:api_token \
                    -H "Content-Type: application/json" \
                    -d '{"time_entry":{
                            "description":"EMSP2390 Reading Response 2",
                            "tags":["break"],
                            "pid":88939415,
                            "created_with":"curl"
                        }}' \
                    -X POST https://www.toggl.com/api/v8/time_entries/start

    # End of break
        #osascript -e 'tell app "System Events" to display dialog\
        #    "Time to get back to work. Would you like to restart the timer?"'
        osascript -e 'display notification "Break over." with title "Pomodoro"'
        say "Break period over."

        read -p "Press any key to end break" -n 1 -s
        echo
        
        # End time tracking
            # Find running time tracker
            currentTimeTracker=$(
                                    curl -v -u $togglApiToken:api_token \
                                    -X GET https://www.toggl.com/api/v8/time_entries/current \
                                    | awk -F 'id' '{print $2}' | cut -d: -f2 | cut -d, -f1
                                )
            # Kill it
            curl -v -u $togglApiToken:api_token \
	                -H "Content-Type: application/json" \
                	-X PUT https://www.toggl.com/api/v8/time_entries/$currentTimeTracker/stop
#done
