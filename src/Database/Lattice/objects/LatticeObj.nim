#Errors lib.
import ../../../lib/Errors

#Numerical libs.
import BN
import ../../../lib/Base

#Hash lib.
import ../../../lib/Hash

#Merit lib.
import ../../Merit/Merit

#Index object.
import IndexObj

#Entry object.
import EntryObj

#Account object.
import AccountObj

#BLS lib.
import ../../../lib/BLS

#Tables standard library.
import tables

#Lattice master object.
type Lattice* = ref object of RootObj
    #Difficulties.
    difficulties*: tuple[transaction: BN, data: BN]

    #Lookup table (hash -> index).
    lookup*: TableRef[
        string,
        Index
    ]

    #Verifications (hash -> list of addresses who signed off on it).
    verifications: TableRef[
        string,
        seq[BLSPublicKey]
    ]

    #Accounts (address -> account).
    accounts*: TableRef[
        string,
        Account
    ]

#Lattice constructor
func newLattice*(
    txDiff: string,
    dataDiff: string
): Lattice {.raises: [ValueError].} =
    #Create the object.
    result = Lattice(
        difficulties: (transaction: txDiff.toBN(16), data: dataDiff.toBN(16)),
        lookup: newTable[string, Index](),
        verifications: newTable[string, seq[BLSPublicKey]](),
        accounts: newTable[string, Account]()
    )

    #Add the minter account.
    result.accounts["minter"] = newAccountObj("minter")

#Add a hash to the lookup.
func addHash*(
    lattice: Lattice,
    hash: Hash[512],
    index: Index
) {.raises: [].} =
    lattice.lookup[$hash] = index

#Add a Verification to the Verifications' table.
proc verify*(
    lattice: Lattice,
    merit: Merit,
    hashArg: Hash[512],
    verifier: BLSPublicKey
): bool {.raises: [KeyError, ValueError].} =
    #Turn the hash into a string.
    var hash: string = $hashArg

    #Verify the Entry exists.
    if not lattice.lookup.hasKey(hash):
        return false
    result = true

    #Create a blank seq if there's not already a seq.
    if not lattice.verifications.hasKey(hash):
        lattice.verifications[hash] = @[]

    #Return if the Verification already exists.
    if lattice.verifications[hash].contains(verifier):
        return

    #Add the Verification.
    lattice.verifications[hash].add(verifier)

    #Calculate the weight.
    var weight: uint = 0
    for i in lattice.verifications[hash]:
        weight += merit.state.getBalance(i)
    #If the Entry has at least 50.1% of the weight...
    if (
        (weight * 100) div
        merit.state.live
    ) >= uint(501):
        #Get the Index of the Entry.
        var index: Index = lattice.lookup[hash]
        lattice.accounts[index.address][index.nonce].verified = true
    echo hash & " was verified."

#Creates a new Account on the Lattice.
func addAccount*(
    lattice: Lattice,
    address: string
) {.raises: [].} =
    #Make sure the account doesn't already exist.
    if lattice.accounts.hasKey(address):
        return

    lattice.accounts[address] = newAccountObj(address)

#Gets an account.
func getAccount*(
    lattice: Lattice,
    address: string
): Account {.raises: [ValueError].} =
    #Call addAccount, which will only create an account if one doesn't exist.
    lattice.addAccount(address)

    #Return the account.
    result = lattice.accounts[address]

#Gets a Entry by its Index.
proc `[]`*(lattice: Lattice, index: Index): Entry {.raises: [ValueError].} =
    if not lattice.accounts.hasKey(index.address):
        raise newException(ValueError, "Lattice does not have an Account for that address.")
    if lattice.accounts[index.address].height <= index.nonce:
        raise newException(ValueError, "The Account for that address doesn't have a Entry for that nonce.")

    result = lattice.accounts[index.address][index.nonce]

#Gets a Entry by its hash.
proc getEntry*(lattice: Lattice, hash: string): Entry {.raises: [ValueError].} =
    if not lattice.lookup.hasKey(hash):
        raise newException(ValueError, "Lattice does not have a Entry for that hash.")

    result = lattice[lattice.lookup[hash]]
