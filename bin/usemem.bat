echo "Setting MaxMem registry value"
regtool -i set "/HKLM/Software/Cygnus Solutions/Cygwin/heap_chunk_in_mb" 1024
echo "Registry values for Cygwin are:"
regtool -v list "/HKLM/Software/Cygnus Solutions/Cygwin"
