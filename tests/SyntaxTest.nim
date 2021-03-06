#Syntax test. Compiles every file to verify the codebase has valid syntax.

#Lib.
import ../src/lib/Errors
import ../src/lib/Util
import ../src/lib/Logger

import ../src/lib/Base
import ../src/lib/Base32

import ../src/lib/BLS

import ../src/lib/libsodium
import ../src/lib/Ed25519

import ../src/lib/Hash
import ../src/lib/Merkle

#Wallet.
import ../src/Wallet/Wallet
import ../src/Wallet/MinerWallet

#Database.
import ../src/Database/Filesystem/Filesystem
import ../src/Database/Lattice/Lattice
import ../src/Database/Merit/Merit

#Network.
import ../src/Network/Serialize/SerializeCommon

import ../src/Network/Serialize/Merit/SerializeBlockHeader
import ../src/Network/Serialize/Merit/SerializeVerifications
import ../src/Network/Serialize/Merit/SerializeMiners
import ../src/Network/Serialize/Merit/SerializeBlock

import ../src/Network/Serialize/Verifications/SerializeVerification
import ../src/Network/Serialize/Verifications/SerializeMemoryVerification

import ../src/Network/Serialize/Lattice/SerializeEntry
import ../src/Network/Serialize/Lattice/SerializeMint
import ../src/Network/Serialize/Lattice/SerializeClaim
import ../src/Network/Serialize/Lattice/SerializeSend
import ../src/Network/Serialize/Lattice/SerializeReceive
import ../src/Network/Serialize/Lattice/SerializeData

import ../src/Network/Serialize/Merit/ParseBlockHeader
import ../src/Network/Serialize/Merit/ParseVerifications
import ../src/Network/Serialize/Merit/ParseMiners
import ../src/Network/Serialize/Merit/ParseBlock

import ../src/Network/Serialize/Verifications/ParseVerification
import ../src/Network/Serialize/Verifications/ParseMemoryVerification

import ../src/Network/Serialize/Lattice/ParseMint
import ../src/Network/Serialize/Lattice/ParseClaim
import ../src/Network/Serialize/Lattice/ParseSend
import ../src/Network/Serialize/Lattice/ParseReceive
import ../src/Network/Serialize/Lattice/ParseData

import ../src/Network/Network

#UI.
import ../src/UI/UI
