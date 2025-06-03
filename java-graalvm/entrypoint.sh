#!/bin/bash

#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

# Print Java version
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mjava -version\n"
java -version

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")
DUMPS_ENABLED=$(echo "$PARSED" | sed -n 's/.*-Ddump=\([^ ]*\).*/\1/p')
TRACE_ENABLED=$(echo "$PARSED" | sed -n 's/.*-Danalyse=\([^ ]*\).*/\1/p')
JEMALLOC_DISABLED=$(echo "$PARSED" | sed -n 's/.*-Djemalloc=false.*/true/p')

if [ -z "$JEMALLOC_DISABLED" ]; then
    export LD_PRELOAD="/usr/local/lib/libjemalloc.so"
fi

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"

# failsafe in case dumps folder does not exist
mkdir -p dumps

# haha we hate nohup
if [ "$DUMPS_ENABLED" = "true" ]; then
    export MALLOC_CONF="prof:true,lg_prof_interval:31,lg_prof_sample:17,prof_prefix:/home/container/dumps/jeprof,background_thread:true,dirty_decay_ms:1000,muzzy_decay_ms:0,narenas:1,tcache_max:1024,abort_conf:true"

    (
        while true; do
            # loop through heapdump files
            for heapfile in dumps/*.heap; do
                if [ -f "$heapfile" ]; then
                    basefilename="${heapfile%.heap}"
                    
                    timestamp=$(date +"%d.%m.%y-%H:%M:%S")
                    
                    gif_output="dumps/output/${basefilename}-${timestamp}.gif"
                    
                    mkdir -p "$(dirname "$gif_output")"
                    
                    jeprof --show_bytes --maxdegree=20 --nodefraction=0 --edgefraction=0 --gif \
                        /opt/java/openjdk/bin/java \
                        "$heapfile" > "$gif_output"
                    
                    # Remove processed heap file
                    rm "$heapfile"
                fi
            done
            
            # Wait one minute before checking again
            sleep 60
        done
    ) &
fi

if [ "$TRACE_ENABLED" = "true" ]; then
    # Extract the keyword from the PARSED variable
    KEYWORD=$(echo "$PARSED" | sed -n 's/.*-Dkeyword=\([^ ]*\).*/\1/p')
    INTERVAL=$(echo "$PARSED" | sed -n 's/.*-Dinterval=\([^ ]*\).*/\1/p')

    if [ -z "$KEYWORD" ]; then
        printf "KEYWORD is empty. Ensure -Dkeyword is set."
        exit 1
    fi
    if [ -z "$INTERVAL" ]; then
        printf "INTERVAL is empty. Ensure -Dinterval is set. (In seconds)"
        exit 1
    fi

    printf "Searching for keyword $KEYWORD\n"

    (
        mkdir -p dumps/traces

        while true; do
            sleep $INTERVAL

            PID=$(pgrep java)
            jstack ${PID} > "profiling.log"

            JVM_LOG="profiling.log"

            if [ -f "$JVM_LOG" ]; then
                timestamp=$(date +"%d.%m.%y-%H:%M:%S")
                TRACE_OUTPUT="dumps/traces/trace-${timestamp}.log"

                if grep -qE "$KEYWORD" "$JVM_LOG"; then
                    cat "$JVM_LOG" > "$TRACE_OUTPUT"

                    printf "Detected keyword ($KEYWORD):" >> "$TRACE_OUTPUT"
                    grep -E "$KEYWORD" "$JVM_LOG" >> "$TRACE_OUTPUT"
                fi
            fi
        done
    ) &
fi

# shellcheck disable=SC2086
exec env ${PARSED}
