function uvx --description 'Run a Python package with uv (one-off execution)'
    if not command -v uv &>/dev/null
        echo "uv is not installed. Install it with: brew install uv"
        return 1
    end

    # Run the package with uv
    command uv tool run $argv
end
