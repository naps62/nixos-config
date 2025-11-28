This command should only work while in a secondary branch (not main or master).

Commit any unstaged changes
Fetch updates from the origin repo
If there are new commits on the parent branch (typically origin/main), then merge them back into the current branch
Solve any conflicts, and analyze the incoming changes to see if additional changes are required to the branch's code (e.g.: if something was renamed in the meantime in main, our new code may need to be adjusted)
