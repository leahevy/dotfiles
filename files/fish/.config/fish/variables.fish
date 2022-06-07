if test -n "$NVIM_LISTEN_ADDRESS"
  set VISUAL "nvr -cc tabedit --remote-wait +'set bufhidden=wipe'"
else
  set VISUAL "nvim -p"
end
