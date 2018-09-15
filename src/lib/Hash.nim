#Hash Master Type/helper functions.
import Hash/HashCommon
export HashCommon.Hash
export HashCommon.toString
export HashCommon.`$`
export HashCommon.toBN

#SHA3 lib (used by Ember).
import Hash/SHA3
export SHA3

#Argon lib (used by Ember).
import Hash/Argon
export Argon

#SHA2 lib (for compatibility with old systems).
import Hash/SHA2
export SHA2

#RipeMD lib (for compatibility with BTC).
import Hash/RipeMD
export RipeMD

#Keccak lib (for compatibility with Ethereum).
import Hash/Keccak
export Keccak

#Hash exponentiation.
#f^n(x) = f(f(f(... n times ... f(f(f(x))))))
proc `^`*[T](algo: proc(x: string): T, power: int): proc(x: string): T {.raises: [Exception].} =
    result = proc(x: string): T {.raises: [Exception].} =
        result = algo(x)
        for _ in 2 .. power:
            result = algo(result.toString())

#Define SHA3 as the default SHA hash family.
type
    SHA256Hash* = SHA3_256Hash
    SHA512Hash* = SHA3_512Hash
var
    SHA256*: proc (input: string): SHA256Hash {.raises: [].} = SHA3_256
    SHA512*: proc (input: string): SHA512Hash {.raises: [].} = SHA3_512
    toSHA256Hash*: proc (input: string): SHA256Hash {.raises: [].} = toSHA3_256Hash
    toSHA512Hash*: proc (input: string): SHA512Hash {.raises: [].} = toSHA3_512Hash