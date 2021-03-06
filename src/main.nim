#The Main files include each other sequentially.
#It starts with MainImports.
#MainImports is included by MainConstants.
#MainConstants is included by MainGlobals.
#MainGlobals is included by MainVerifications.
#MainVerifications is included by MainMerit.
#MainMerit is included by MainLattice.
#MainLattice is included by MainPersonal.
#MainPersonal is included by MainNetwork.
#MainNetwork is included by MainUI.
#It ends with include MainUI.

#We could include all of them in this file, but then all the other files would throw errors.
#IDEs can't, and shouldn't, detect that an external file includes that file, and the external file resolves the dependencies.

#Include the last file in the sequence.
include MainUI

#Spawn the core stuff on a thread since the UI must be on the main thread.
proc main() {.thread.} =
    mainVerifications()
    mainMerit()
    mainLattice()
    mainPersonal()
    mainNetwork()
    mainRPC()

    runForever()
spawn main()

#Spawn the GUI.
mainGUI()

#Sync up with the main thread.
sync()
