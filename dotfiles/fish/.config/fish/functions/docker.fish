function docker
    if test -n "$argv[1]"
        switch $argv[1]
            #          case ps
            #      dops $argv[2..-1]
            case '*'
                command docker $argv[1..-1]
        end
    end
end
