# Copyright © 2019 Marcel Kapfer <opensource@mmk2410.org>
# MIT License

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if status --is-interactive
    alias grep="grep --color=auto"
    alias df="df -h"
    alias du="du -c -h"
    alias mkdir="mkdir -p -v"
    alias ln="ln -i"
    alias psa="ps aux"
    alias q="exit"
    alias Q="exit"
    alias x="exit"
    alias o="open"
    alias vim="nvim"
    alias e="es"
    alias rmdot="rm -rf .[!.]*"
    alias sudoedit="sudo $EDITOR"
    alias rs="exec $SHELL"

    # Docker
    alias dps="docker ps"
    alias dpsa="docker ps -a"
    alias dim="docker images"
    alias dl="docker logs -f"
    alias di="docker inspect"
    alias dnames="docker ps --format '{{.Names}}'"
    alias dip="docker ps -q | xargs -n 1 docker inspect --format '{{.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' | sed 's/^\///' | column -t"
    alias drmc="docker rm (docker ps -aq -f status=exited)"
    alias drmid="docker rmi (docker images -qf dangling=true)"

    # Docker Compose
    alias dc="docker compose"
    alias dcu="docker compose up -d"
    alias dcd="docker compose down"
    alias dcr="docker compose run"
end

# Docker functions
function dex -d "Execute bash shell in running container"
    docker exec -it $argv[1] /bin/bash
end

function drun -d "Run bash shell in new container from image"
    docker run -it --rm $argv[1] /bin/bash
end

function dsr -d "Stop then remove container"
    docker stop $argv[1] && docker rm $argv[1]
end
