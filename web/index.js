console.log('External JS file linked');

console.log('This is the web index.js file');
// Function to generate a random alphanumeric string of specified length
function generateRandomString(length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
}

// Function to generate a random numeric string of specified length
function generateRandomNumericString(length) {
    const digits = '0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += digits.charAt(Math.floor(Math.random() * digits.length));
    }
    return result;
}

// Generate random strings
// const randomName = generateRandomString(3);
// const randomIdentity = generateRandomNumericString(8); // Numeric string of length 8
// const randomEmail = `${randomName}@gmail.com`; // Combine random string with "@gmail.com"


// call this when a user login form is submitted.

// console.log(`The emailId is ${randomEmail}`);
// console.log(`The Identity is ${randomIdentity}`);

// for web push notification.
document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('pushNotifBtn').addEventListener('click', function () {
      console.log('tapped');
      var pushData = {
        'titleText': 'Would you like to receive Push Notifications?',
        'bodyText':
            'We promise to only send you relevant content and give you updates on your transactions',
        'okButtonText': 'Ok',
        'rejectButtonText': 'Cancel',
        'okButtonColor': '#F28046',
        'askAgainTimeInSeconds': 5,
        'serviceWorkerPath': '/clevertap_sw.js'
      };
      CleverTapPlugin.enableWebPush(pushData);
    });
  });
  
// document.getElementById('productviewed').addEventListener('click', function(){
//     console.log('product Viewed');
//     cleverTap.event.push("Product viewed");
// });


