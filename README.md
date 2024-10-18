If I put a List in a utility panel that becomesKeyOnlyWhenNeeded, it becomes unresponsive once the panel loses key status.

Build and run the attached sample application
Steps are in the app window, but for completeness…

                   • Open the popover with List
                   • Test that tap select/deselcts rows
                   • Detach the popover. This results in an NSPanel that is the application key window for the moment
                   • Test that tap works
                   • Click on the main window
                   • Test that tap no longer works
                   • Note that the chevron still works
                   • Note that selection in the other popover doesn't exhibit this bug
