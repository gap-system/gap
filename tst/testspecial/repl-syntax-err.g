# see <https://github.com/gap-system/gap/issues/4188>
# we need a line with a statement that gets executed by the immediate
# interpreter before running into a syntax error (here: a colon instead
# of a semicolon); this leads to a break loop which we quit; the syntax
# error then is displayed. The next line then contains another syntax
# error, which wasn't reported correctly before the above issues was
# fixed.
Error(""):
quit;
1:
