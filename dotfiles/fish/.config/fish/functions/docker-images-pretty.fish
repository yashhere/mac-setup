function docker-images-pretty -d "Display Docker images with platform information in a pretty format"
    # Print header
    set_color -o cyan
    printf "%-60s | %-15s | %-20s\n" "IMAGE" "ID" "PLATFORM"
    set_color normal
    set_color -o cyan
    printf "%s\n" "─────────────────────────────────────────────────────────────|─────────────────|────────────────────────"
    set_color normal
    
    # Get images and their details
    docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}' | while read -l name id
        set platform (docker image inspect $id --format '{{.Os}}/{{.Architecture}}')
        
        # Colorize output
        set_color yellow
        printf "%-60s" "$name"
        set_color normal
        printf " | "
        set_color green
        printf "%-15s" "$id"
        set_color normal
        printf " | "
        set_color blue
        printf "%-20s" "$platform"
        set_color normal
        printf "\n"
    end
end
