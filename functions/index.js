const functions = require('firebase-functions');
const admin = require('firebase-admin');
const QRCode = require('qrcode');

// Initialize Firebase Admin SDK
admin.initializeApp();

const firestore = admin.firestore();

// Function to fetch data from Firebase using account number
async function fetchDataFromFirebase(accountNumber) {
    // Your existing function implementation
    try {
        const querySnapshot = await getDocs(query(collection(firestore, 'users'), where('account_no', '==', accountNumber)));
        if (querySnapshot.empty) {
            throw new Error('No user found with this account number!');
        }
        const userData = querySnapshot.docs[0].data();
        userData.id = querySnapshot.docs[0].id;
        return userData;
    } catch (error) {
        console.error('Error fetching data from Firebase:', error);
        throw error;
    }
}

// Function to generate QR code data URL
async function generateQRCodeDataUrl(senderAccountNumber, receiverAccountNumber, amount) {
    // Your existing function implementation
    try {
        const qrCodeData = {
            senderAccountNumber,
            receiverAccountNumber,
            amount
        };

        const qrCodeDataString = JSON.stringify(qrCodeData);

        const qrCodeDataUrl = await QRCode.toDataURL(qrCodeDataString);

        return qrCodeDataUrl;
    } catch (error) {
        console.error('Error generating QR code data URL:', error);
        throw error;
    }
}

// Define Cloud Function to handle HTTP requests for processing QR code
exports.processQRCode = functions.https.onRequest(async (req, res) => {
    try {
        // Your existing HTTP request handling logic goes here
    } catch (error) {
        console.error('Error handling request:', error);
        res.status(500).send('Internal Server Error');
    }
});

// Export other functions if needed
