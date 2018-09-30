#BN lib.
import BN

#Import the Wallet lib.
import ../../Wallet/Wallet

#GUI object.
import objects/GUIObj
export GUIObj

#JS Bindings.
import Bindings/Bindings

#Events lib.
import ec_events

#WebView.
import ec_webview

#Async standard lib.
import asyncdispatch

#String utils standard lib.
import strutils

#Constructor.
proc newGUI*(
    events: EventEmitter,
    width: int,
    height: int
) {.thread, raises: [Exception].} =
    #Create the GUI.
    var gui: GUI = newGUI(
        events,
        newWebView(
            "Ember Core",
            "",
            width,
            height
        )
    )

    #Add the Bindings.
    gui.createBindings()

    #Load the main page.
    if gui.webview.eval(
        "document.body.innerHTML = (\"" & MAIN.splitLines().join("\"+\"") & "\");"
    ) != 0:
        raise newException(Exception, "Couldn't evaluate JS in the WebView.")

    #Run the GUI.
    gui.webview.run()