include MainVerifications

proc mainMerit() {.raises: [
    ValueError,
    ArgonError
].} =
    {.gcsafe.}:
        #Create the Merit.
        merit = newMerit(GENESIS, BLOCK_TIME, BLOCK_DIFFICULTY, LIVE_MERIT)

        #Handle requests for the current height.
        functions.merit.getHeight = proc (): uint {.raises: [].} =
            merit.blockchain.height

        #Handle requests for the current Difficulty.
        functions.merit.getDifficulty = proc (): BN {.raises: [].} =
            merit.blockchain.difficulties[^1].difficulty

        #Handle requests for a Block.
        functions.merit.getBlock = proc (nonce: uint): Block {.raises: [].} =
            merit.blockchain.blocks[int(nonce)]

        #Handle full blocks.
        functions.merit.addBlock = proc (newBlock: Block): Future[bool] {.async.} =
            result = true

            #Print that we're adding the Block.
            echo "Adding a new Block. " & $newBlock.header.nonce

            #If we're connected to other people, sync missing info.
            if network.clients.clients.len > 0:
                #Check if we're missing previous Blocks.
                if newBlock.header.nonce > merit.blockchain.height:
                    #Iterate over the missing Blocks.
                    for nonce in uint(merit.blockchain.height) ..< newBlock.header.nonce:
                        #Get and test the Block.
                        try:
                            if not await network.requestBlock(nonce):
                                raise newException(Exception, "")
                        except:
                            echo "Failed to add the Block."
                            return false

                #Missing Verifications/Entries.
                if not await network.sync(newBlock):
                    echo "Failed to add the Block."
                    return false

            if newBlock.verifications.len > 0:
                #Verify we have all the Verifications and Entries, as well as verify the signature.
                var agInfos: seq[ptr BLSAggregationInfo] = @[]
                for index in newBlock.verifications:
                    #Verify we have the Verifier.
                    if not verifications.hasKey(index.key):
                        echo "Failed to add the Block."
                        return false

                    #Verify this isn't archiving archived Verifications.
                    if index.nonce < verifications[index.key].archived:
                        echo "Failed to add the Block."
                        return false

                    #Verify we have all the Verifications.
                    if index.nonce >= verifications[index.key].height:
                        echo "Failed to add the Block."
                        return false

                    #Check the merkle.
                    if verifications[index.key].calculateMerkle(index.nonce) != index.merkle:
                        echo "Failed to add the Block."
                        return false

                    #Start of this verifier's unarchived verifications.
                    var verifierStart: uint = verifications[index.key].archived + 1
                    #Override to handle how archived is 0 twice.
                    if verifierStart == 1:
                        if verifications[index.key][0].archived == 0:
                            verifierStart = 0

                    var
                        #Grab this Verifier's verifications.
                        verifierVerifs: seq[Verification] = verifications[index.key][verifierStart .. index.nonce]
                        #Declare an aggregation info seq for this verifier.
                        verifierAgInfos: seq[ptr BLSAggregationInfo] = newSeq[ptr BLSAggregationInfo](verifierVerifs.len)
                    for v in 0 ..< verifierVerifs.len:
                        #Make sure the Lattice has this Entry.
                        if not lattice.lookup.hasKey(verifierVerifs[v].hash.toString()):
                            return false

                        #Create an aggregation info for this verification.
                        verifierAgInfos[v] = cast[ptr BLSAggregationInfo](alloc0(sizeof(BLSAggregationInfo)))
                        verifierAgInfos[v][] = newBLSAggregationInfo(verifierVerifs[v].verifier, verifierVerifs[v].hash.toString())

                    #Add the Verifier's aggregation info to the seq.
                    agInfos.add(cast[ptr BLSAggregationInfo](alloc0(sizeof(BLSAggregationInfo))))
                    agInfos[^1][] = verifierAgInfos.aggregate()
                #Add the aggregate info to the signature.
                newBlock.header.verifications.setAggregationInfo(agInfos.aggregate())
                if not newBlock.header.verifications.verify():
                    echo "Failed to add the Block."
                    return false

            #Add the Block to the Merit.
            var rewards: Rewards
            try:
                rewards = merit.processBlock(verifications, newBlock)
            except:
                echo "Failed to add the Block."
                return false

            #Archive the Verifications mentioned in the Block.
            verifications.archive(newBlock.verifications, newBlock.header.nonce)

            #Create the Mints (which ends up minting a total of 50000 MR).
            var
                #Nonce of the Mint.
                mintNonce: uint
                #Any Claim we may create.
                claim: Claim
            for reward in rewards:
                mintNonce = lattice.mint(
                    reward.key,
                    newBN(reward.score) * newBN(50) #This is a BN because 50 will end up as a much bigger number (decimals).
                )

                #If we have wallets...
                if (wallet != nil) and (minerWallet != nil):
                    #Check if we're the one getting the reward.
                    if minerWallet.publicKey.toString() == reward.key:
                        #Claim the Reward.
                        var claim: Claim = newClaim(
                            mintNonce,
                            lattice.getAccount(wallet.address).height
                        )
                        #Sign the claim.
                        claim.sign(minerWallet, wallet)

                        #Emit it.
                        try:
                            if not functions.lattice.addClaim(claim):
                                raise newException(Exception, "")
                        except:
                            raise newException(EventError, "Couldn't get and call lattice.claim.")

            echo "Successfully added the Block."

            #Broadcast the Block.
            await network.broadcast(
                newMessage(
                    MessageType.Block,
                    newBlock.serialize()
                )
            )

            #If we made a Claim...
            if not claim.isNil:
                #Broadcast the Claim.
                await network.broadcast(
                    newMessage(
                        MessageType.Claim,
                        claim.serialize()
                    )
                )
