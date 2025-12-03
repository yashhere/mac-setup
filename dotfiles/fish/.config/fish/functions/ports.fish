function ports -d "Show listening ports and their processes"
    set -l port $argv[1]

    if test -n "$port"
        # Show specific port
        echo "Checking port $port..."
        lsof -i :$port -P -n 2>/dev/null
        
        if test $status -ne 0
            echo "No process found on port $port"
        end
    else
        # Show all listening ports
        echo "Listening ports:"
        echo
        printf "%-8s %-24s %-8s %-12s\n" "PORT" "PROCESS" "PID" "USER"
        echo "────────────────────────────────────────────────────────"
        
        lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | tail -n +2 | while read -l cmd pid user fd type device size node name
            # Extract port from name (e.g., *:3000 or 127.0.0.1:3000)
            set -l port_num (string replace -r '.*:' '' $name)
            printf "%-8s %-24s %-8s %-12s\n" $port_num $cmd $pid $user
        end | sort -t' ' -k1 -n | uniq
    end
end
