VERSION := "4.dev";
DATE := "today";
if KERNEL_VERSION<>"4.3.0" then
  Error("You are running a GAP kernel which does not fit with the library.\n",
        "Probably you forgot to apply the kernel part or the library part\n",
	"of a bugfix?\n");
fi;
