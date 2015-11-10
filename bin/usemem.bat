echo "Setting MaxMem registry value"
regtool -i set "/HKCU/Software/Cygwin/heap_chunk_in_mb" 1024
echo "Registry values for Cygwin are:"
regtool -v list "/HKCU/Software/Cygwin"
