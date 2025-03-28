function fix-git-author
    if test (count $argv) -ne 4
        echo "Usage: fix-git-author OLD_NAME NEW_NAME OLD_EMAIL NEW_EMAIL"
        return 1
    end

    set old_name $argv[1]
    set new_name $argv[2]
    set old_email $argv[3]
    set new_email $argv[4]

    git filter-repo --name-callback "return name.replace(b'$old_name', b'$new_name')" \
        --email-callback "return email.replace(b'$old_email', b'$new_email')"
end
