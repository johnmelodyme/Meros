discard """
This lib is special, in a couple of ways.
- It is prefixed by Main, and directly under src/, but it is NOT part of the include chain.
- It's not even a lib, but an object file.

This is a replacement for the previously used EventEmitters (mc_events).
It's type safe, and serves the same purpose, yet provides an even better API.
That said, we lose the library format, and instead have this.
This is annoying, but we no longer have to specify the type when we call events, so we break even.
"""

#Errors lib.
import lib/Errors

#BN lib.
import BN

#BLS lib.
import lib/BLS

#Message object.
import Network/objects/MessageObj

#Wallet.
import Wallet/Wallet

#Verifications.
import Database/Verifications/Verifications

#Merit.
import Database/Merit/Merit

#Lattice.
import Database/Lattice/Lattice

#Finals lib.
import finals

#Async lib.
import asyncdispatch

type
    SystemFunctionBox* = ref object of RootObj
        quit*: proc () {.raises: [ChannelError, AsyncError, SocketError].}

    VerificationsFunctionBox* = ref object of RootObj
        getVerifierHeight*:     proc (key: string): uint                           {.raises: [KeyError].}
        getVerification*:       proc (key: string, nonce: uint): Verification      {.raises: [KeyError].}
        getUnarchivedIndexes*:  proc (): seq[VerifierIndex]                        {.raises: [KeyError, ValueError, FinalAttributeError].}
        getPendingAggregate*:   proc (verifier: string, nonce: uint): BLSSignature {.raises: [KeyError, BLSError].}
        getPendingHashes*:      proc (key: string, nonce: uint): seq[string]       {.raises: [KeyError].}

        addVerification*:        proc (verif: Verification): bool       {.raises: [ValueError].}
        addMemoryVerification*:  proc (verif: MemoryVerification): bool {.raises: [ValueError, BLSError].}

    MeritFunctionBox* = ref object of RootObj
        getHeight*:      proc (): uint             {.raises: [].}
        getDifficulty*:  proc (): BN               {.raises: [].}
        getBlock*:       proc (nonce: uint): Block {.raises: [].}

        addBlock*:  proc (newBlock: Block): Future[bool]

    LatticeFunctionBox* = ref object of RootObj
        getHeight*:        proc (account: string): uint {.raises: [ValueError].}
        getBalance*:       proc (account: string): BN   {.raises: [ValueError].}
        getEntryByHash*:   proc (hash: string): Entry   {.raises: [KeyError, ValueError].}
        getEntryByIndex*:  proc (index: Index): Entry   {.raises: [ValueError].}

        addClaim*:    proc (claim: Claim): bool  {.raises: [ValueError, AsyncError, BLSError, SodiumError].}
        addSend*:     proc (send: Send): bool    {.raises: [ValueError, EventError, AsyncError, BLSError, SodiumError, FinalAttributeError].}
        addReceive*:  proc (recv: Receive): bool {.raises: [ValueError, AsyncError, BLSError, SodiumError].}
        addData*:     proc (data: Data): bool    {.raises: [ValueError, AsyncError, BLSError, SodiumError].}

    PersonalFunctionBox* = ref object of RootObj
        getWallet*:  proc (): Wallet {.raises: [].}

        setSeed*:      proc (seed: string)     {.raises: [ValueError, RandomError, SodiumError].}
        signSend*:     proc (send: Send): bool {.raises: [ValueError, SodiumError, FinalAttributeError].}
        signReceive*:  proc (recv: Receive)    {.raises: [SodiumError, FinalAttributeError].}
        signData*:     proc (data: Data): bool {.raises: [ValueError, SodiumError, FinalAttributeError].}

    NetworkFunctionBox* = ref object of RootObj
        connect*:    proc (ip: string, port: uint): Future[bool]
        broadcast*:  proc (msgType: MessageType, msg: string): Future[void]

    MainFunctionBox* = ref object of RootObj
        system*:         SystemFunctionBox
        verifications*:  VerificationsFunctionBox
        merit*:          MeritFunctionBox
        lattice*:        LatticeFunctionBox
        personal*:       PersonalFunctionBox
        network*:        NetworkFunctionBox

#Constructor.
proc newMainFunctionBox*(): MainFunctionBox {.raises: [].} =
    MainFunctionBox(
        system:        SystemFunctionBox(),
        verifications: VerificationsFunctionBox(),
        merit:         MeritFunctionBox(),
        lattice:       LatticeFunctionBox(),
        personal:      PersonalFunctionBox(),
        network:       NetworkFunctionBox()
    )
