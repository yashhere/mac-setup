function ls --wraps eza --description "alias ls=eza"
    if type -q eza
        eza $argv
    else
        command ls $argv
    end
end