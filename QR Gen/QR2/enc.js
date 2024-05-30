const assert = require('node:assert');
const { MongoClient, ServerApiVersion, AutoEncryptionLoggerLevel } = require('mongodb');
const fs = require('fs')

const uri = "mongodb+srv://rio:root@cluster0.y4qh2ob.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

const client = new MongoClient(uri, {
    serverApi: {
        version: ServerApiVersion.v1,
        strict: false,
        deprecationErrors: true,
    }
});
const dbo = client.db('KeysDB').collection('PublicKeys');

const {
    createDiffieHellman,
} = require('node:crypto');

async function alice_generator() {
    // Generate Alice's keys...
    const alice = createDiffieHellman(2048);
    const alicePublicKey = alice.generateKeys().toString('base64');
    const alice_prime = alice.getPrime('base64');
    const alice_generator = alice.getGenerator('base64');
    fs.writeFileSync('./key', alice.generateKeys().toString('base64'), { encoding: 'utf-8' });
    var myobj = { accno: 123456, Pubkey: alicePublicKey, generator: alice_generator, prime: alice_prime };
    result = await dbo.insertOne(myobj);
    console.log(result);
}
alice_generator()

// Generate Bob's keys...
async function bob_gen() {
    const alicePublicKey_new = await dbo.findOne({ accno: 123456 });
    const bob = createDiffieHellman(alicePublicKey_new.prime, alicePublicKey_new.generator);
    const bobPublicKey = bob.generateKeys().toString('base64');
    const bob_prime = bob.getPrime('base64');
    const bob_generator = bob.getGenerator('base64');
    var myobj = { accno: 123457, Pubkey: bobPublicKey, generator: bob_generator, prime: bob_prime };
    result = await dbo.insertOne(myobj);
}
bob_gen()
// Exchange and generate the secret...
async function sec_gen() {
    const bobPublicKey_new = await dbo.findOne({ accno: 123457 });
    const alicePublicKey_new = await dbo.findOne({ accno: 123456 });

    const aliceDH = createDiffieHellman(alicePublicKey_new.prime, alicePublicKey_new.generator);
    const bobDH = createDiffieHellman(bobPublicKey_new.prime, bobPublicKey_new.generator);
    // aliceDH.setPublicKey(alicePublicKey_new.Pubkey, 'hex');
    // aliceDH.setPublicKey(bobPublicKey_new.Pubkey, 'hex');
    // var key = Buffer.from(bobPublicKey_new.Pubkey, 'base64');
    var key = Buffer.from(fs.readFileSync('./key', { encoding: 'utf-8' }), 'base64');
    const bobSecret = bobDH.computeSecret(key);
    console.log(aliceSecret);
    console.log(bobSecret);

    console.log(aliceSecret == bobSecret);
}
sec_gen();