import React, { useState } from 'react';
import {
    View,
    TextInput,
    Button,
    Alert,
    StyleSheet,
    Text,
    ActivityIndicator,
    TouchableOpacity,
    ScrollView, // Added ScrollView for smaller screens
    SafeAreaView,
} from 'react-native';
import auth, { FirebaseAuthTypes } from '@react-native-firebase/auth';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { LoginManager, AccessToken } from 'react-native-fbsdk-next';
// Uncomment if implementing username login fully
// import firestore from '@react-native-firebase/firestore';
import type { StackNavigationProp } from '@react-navigation/stack';
import type { AuthStackParamList } from '../navigation/AuthNavigator'; // Use 'import type'

// --- Configure Google Sign In ---
// IMPORTANT: Make sure you have your webClientId
// You can place this configuration call in a higher-level component like App.tsx if preferred
try {
    GoogleSignin.configure({
        webClientId: 'YOUR_WEB_CLIENT_ID', // Replace with your actual Web Client ID
    });
    console.log('Google Signin Configured');
} catch (error) {
    console.error("Google Signin configuration error:", error);
}

// --- Navigation Prop Type ---
type LoginScreenNavigationProp = StackNavigationProp<AuthStackParamList, 'Login'>;

type Props = {
    navigation: LoginScreenNavigationProp;
};

const LoginScreen: React.FC<Props> = ({ navigation }) => {
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    // --- State for Email/Pass/Username ---
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [username, setUsername] = useState('');
    const [isPasswordSecure, setIsPasswordSecure] = useState(true);

    // --- State for Phone ---
    const [phoneNumber, setPhoneNumber] = useState('');
    const [confirm, setConfirm] = useState<FirebaseAuthTypes.ConfirmationResult | null>(null);
    const [code, setCode] = useState('');

    const handleLoginError = (err: any) => {
        console.error("Login Error:", err.code, err.message);
        // Provide more user-friendly messages
        let friendlyMessage = 'An unknown error occurred.';
        switch (err.code) {
            case 'auth/invalid-email':
                friendlyMessage = 'Please enter a valid email address.';
                break;
            case 'auth/user-disabled':
                friendlyMessage = 'This user account has been disabled.';
                break;
            case 'auth/user-not-found':
            case 'auth/wrong-password':
                friendlyMessage = 'Invalid email or password.';
                break;
            case 'auth/invalid-credential': // General credential error (often social logins)
                 friendlyMessage = 'Invalid credentials. Please try again.';
                 break;
            case 'auth/network-request-failed':
                friendlyMessage = 'Network error. Please check your connection.';
                break;
            case 'auth/too-many-requests':
                 friendlyMessage = 'Too many login attempts. Please try again later.';
                 break;
             case 'auth/invalid-phone-number':
                  friendlyMessage = 'Invalid phone number format.';
                  break;
              case 'auth/invalid-verification-code':
                   friendlyMessage = 'Invalid verification code.';
                   break;
            case 'firestore/unavailable':
                 friendlyMessage = 'Could not connect to database. Check connection.'
                 break;
             // Add more specific Firebase error codes as needed
            default:
                friendlyMessage = err.message || friendlyMessage;
        }
        setError(friendlyMessage);
        setLoading(false);
        setConfirm(null); // Reset phone confirmation state on error
    };

    // --- Email/Password Login ---
    const handleEmailPasswordLogin = async () => {
        if (!email || !password) {
            setError("Please enter both email and password.");
            return;
        }
        setLoading(true);
        setError(null);
        try {
            await auth().signInWithEmailAndPassword(email, password);
            console.log('Email/Pass Login Success');
            // Navigation happens via AuthProvider listener in App.tsx
        } catch (err: any) {
            handleLoginError(err);
        } finally {
             setLoading(false);
        }
    };

    // --- Username/Password Login (Requires Firestore Lookup) ---
    const handleUsernamePasswordLogin = async () => {
         // !! IMPORTANT: Firebase Auth doesn't directly support username login.
        // This requires looking up the email associated with the username in Firestore.
        if (!username || !password) {
             setError("Please enter both username and password.");
             return;
        }
        setLoading(true);
        setError(null);
        try {
            // ----- Firestore Implementation (Uncomment and adjust) -----
            /*
            const usersRef = firestore().collection('users'); // Replace 'users' with your collection name
            const snapshot = await usersRef.where('username', '==', username.toLowerCase()).limit(1).get(); // Use lowerCase for case-insensitivity

            if (snapshot.empty) {
                // Use a generic error to avoid revealing if a username exists
                throw { code: 'auth/user-not-found' };
            }

            const userData = snapshot.docs[0].data();
            const userEmail = userData?.email; // Ensure email field exists

            if (!userEmail) {
                 console.error("Firestore data missing email for username:", username);
                 throw new Error('Username configuration error.'); // Internal error
            }

            // Attempt Firebase login using the retrieved email
            await auth().signInWithEmailAndPassword(userEmail, password);
            console.log('Username/Pass Login Success');
            */
            // ----- End Firestore Implementation -----

            // --- Placeholder if Firestore isn't set up ---
             Alert.alert("Not Implemented", "Username/Password login requires database integration (e.g., Firestore) to map username to email. See code comments.");
             throw new Error('Username/Password login not fully implemented.');
             // --- End Placeholder ---

        } catch (err: any) {
            // If using the Firestore lookup, handle potential Firestore errors too
             handleLoginError(err);
        } finally {
            setLoading(false);
        }
    };


    // --- Google Login ---
    const handleGoogleLogin = async () => {
        setLoading(true);
        setError(null);
        try {
            console.log('Starting Google Sign In...');
            await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
            console.log('Play Services checked.');
            const { idToken } = await GoogleSignin.signIn();
            console.log('Google User Token received.');
            const googleCredential = auth.GoogleAuthProvider.credential(idToken);
            await auth().signInWithCredential(googleCredential);
            console.log('Google Login Success');
        } catch (err: any) {
            if (err.code === 'SIGN_IN_CANCELLED') {
                console.log('Google sign-in cancelled by user.');
                setError('Google sign-in cancelled.');
                setLoading(false);
            } else {
                handleLoginError(err);
            }
        } finally {
            // setLoading(false); // Already handled in handleLoginError or success path
        }
    };

    // --- Facebook Login ---
    const handleFacebookLogin = async () => {
         setLoading(true);
         setError(null);
         try {
             console.log('Requesting FB login permissions...');
             const result = await LoginManager.logInWithPermissions(['public_profile', 'email']);
             console.log('FB Login Result:', result);

             if (result.isCancelled) {
                 console.log('Facebook login cancelled by user.');
                 setError('Facebook login cancelled.');
                 setLoading(false); // Explicitly set loading false on cancellation
                 return;
             }

             console.log('Getting FB Access Token...');
             const data = await AccessToken.getCurrentAccessToken();
             if (!data) {
                 throw new Error('Could not get Facebook access token.');
             }
             console.log('FB Access Token received.');
             const facebookCredential = auth.FacebookAuthProvider.credential(data.accessToken);
             await auth().signInWithCredential(facebookCredential);
             console.log('Facebook Login Success');
         } catch (err: any) {
             handleLoginError(err);
         } finally {
              // setLoading(false); // Already handled
         }
    };

    // --- Phone Number Login (Step 1: Send Code) ---
    const handlePhoneSendCode = async () => {
        // Basic validation, consider a lib like 'google-libphonenumber' for robust validation
        if (!phoneNumber || phoneNumber.length < 10) {
             setError("Please enter a valid phone number with country code (e.g., +1 650 555 1234).");
             return;
        }
         setLoading(true);
         setError(null);
         setConfirm(null);
        try {
            // Add reCAPTCHA if needed/configured in Firebase Console
            console.log('Sending phone verification code to:', phoneNumber);
            const confirmation = await auth().signInWithPhoneNumber(phoneNumber);
            setConfirm(confirmation);
            console.log('Verification code sent!');
            Alert.alert('Code Sent', `Enter the verification code sent to ${phoneNumber}`);
         } catch (err: any) {
            handleLoginError(err);
        } finally {
             setLoading(false);
        }
    };

    // --- Phone Number Login (Step 2: Confirm Code) ---
    const handlePhoneConfirmCode = async () => {
        if (!code || !confirm) {
             setError("Please enter the code first.");
             return;
        }
         setLoading(true);
         setError(null);
         try {
            console.log('Confirming phone code:', code);
            await confirm.confirm(code);
            console.log('Phone Login Success');
            setConfirm(null); // Clear confirmation state
            setCode(''); // Clear code input
         } catch (err: any) {
            handleLoginError(err);
        } finally {
             setLoading(false);
        }
    };

    // --- Forgot Password ---
    const handleForgotPassword = () => {
        if (!email) {
            setError('Please enter your email address first to reset password.');
            return;
        }
        setLoading(true);
        setError(null);
        auth()
            .sendPasswordResetEmail(email)
            .then(() => {
                setLoading(false);
                Alert.alert('Password Reset Email Sent', `An email has been sent to ${email} with instructions to reset your password.`);
            })
            .catch((err) => {
                 setLoading(false);
                 handleLoginError(err); // Use existing error handler
            });
    };


    return (
        <SafeAreaView style={styles.safeArea}>
            <ScrollView contentContainerStyle={styles.scrollContainer}>
                <View style={styles.container}>
                    <Text style={styles.title}>Login</Text>

                    {error && <Text style={styles.errorText}>{error}</Text>}
                    {loading && <ActivityIndicator size="large" color="#6366f1" style={styles.loader} />}

                    {/* --- Login Forms (Hide during phone confirmation) --- */}
                    {!confirm && (
                    <>
                        {/* Email/Password Login */}
                        <View style={styles.inputGroup}>
                            <Text style={styles.inputLabel}>Email</Text>
                            <TextInput
                                style={styles.input}
                                placeholder="you@example.com"
                                value={email}
                                onChangeText={setEmail}
                                keyboardType="email-address"
                                autoCapitalize="none"
                                autoComplete="email"
                                editable={!loading}
                            />
                            <Text style={styles.inputLabel}>Password</Text>
                            <View style={styles.passwordContainer}>
                                <TextInput
                                    style={styles.inputPassword}
                                    placeholder="Password"
                                    value={password}
                                    onChangeText={setPassword}
                                    secureTextEntry={isPasswordSecure}
                                    autoCapitalize="none"
                                    autoComplete="password"
                                    editable={!loading}
                                />
                                <TouchableOpacity onPress={() => setIsPasswordSecure(!isPasswordSecure)} style={styles.eyeButton}>
                                    <Text>{isPasswordSecure ? 'Show' : 'Hide'}</Text>
                                </TouchableOpacity>
                            </View>
                            <TouchableOpacity onPress={handleForgotPassword} disabled={loading}>
                                 <Text style={styles.forgotPassword}>Forgot Password?</Text>
                            </TouchableOpacity>
                            <Button title="Login with Email" onPress={handleEmailPasswordLogin} disabled={loading} color="#6366f1" />
                        </View>

                        {/* Username/Password Login */}
                         <View style={styles.inputGroup}>
                             <Text style={styles.inputLabel}>Or Login with Username</Text>
                             <TextInput
                                 style={styles.input}
                                 placeholder="Your Username"
                                 value={username}
                                 onChangeText={setUsername}
                                 autoCapitalize="none"
                                 editable={!loading}
                             />
                             {/* Reuses password state/input */}
                              <Button title="Login with Username" onPress={handleUsernamePasswordLogin} disabled={loading} color="#6366f1" />
                         </View>

                         <View style={styles.separatorContainer}>
                            <View style={styles.separatorLine} />
                            <Text style={styles.separatorText}>OR</Text>
                            <View style={styles.separatorLine} />
                         </View>

                        {/* --- Social & Phone Buttons --- */}
                        <View style={styles.buttonGroup}>
                            <Button title="Sign in with Google" onPress={handleGoogleLogin} disabled={loading} color="#DB4437" />
                            <View style={styles.buttonSpacer} />
                            <Button title="Sign in with Facebook" onPress={handleFacebookLogin} disabled={loading} color="#4267B2" />
                            {/* Add Apple Sign In if needed */}
                        </View>

                        <View style={styles.separatorContainer}>
                             <View style={styles.separatorLine} />
                             <Text style={styles.separatorText}>OR</Text>
                             <View style={styles.separatorLine} />
                         </View>

                         {/* Phone Login */}
                         <View style={styles.inputGroup}>
                            <Text style={styles.inputLabel}>Login with Phone</Text>
                             <TextInput
                                 style={styles.input}
                                 placeholder="Phone Number (e.g., +16505551234)"
                                 value={phoneNumber}
                                 onChangeText={setPhoneNumber}
                                 keyboardType="phone-pad"
                                 autoComplete="tel"
                                 editable={!loading}
                             />
                             <Button title="Send Verification Code" onPress={handlePhoneSendCode} disabled={loading || !!confirm} color="#075e54"/>
                         </View>
                     </>
                     )}

                     {/* --- Phone Code Confirmation --- */}
                     {confirm && (
                         <View style={styles.inputGroup}>
                             <Text style={styles.inputLabel}>Enter Verification Code</Text>
                             <TextInput
                                 style={styles.input}
                                 placeholder="6-digit code"
                                 value={code}
                                 onChangeText={setCode}
                                 keyboardType="number-pad"
                                 editable={!loading}
                             />
                             <View style={styles.buttonGroup}>
                                 <Button title="Confirm Code & Login" onPress={handlePhoneConfirmCode} disabled={loading} color="#075e54" />
                                 <View style={styles.buttonSpacer} />
                                 <Button title="Cancel" onPress={() => { setConfirm(null); setError(null); setCode(''); }} disabled={loading} color="#aaa" />
                             </View>
                         </View>
                     )}


                    <View style={styles.footer}>
                        <Text>Don't have an account?</Text>
                        <TouchableOpacity onPress={() => navigation.navigate('SignUp')} disabled={loading || !!confirm}>
                            <Text style={styles.linkText}> Sign Up</Text>
                        </TouchableOpacity>
                    </View>
                </View>
            </ScrollView>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    safeArea: {
        flex: 1,
        backgroundColor: '#f8f9fa', // Light background
    },
    scrollContainer: {
        flexGrow: 1,
        justifyContent: 'center',
    },
    container: {
        flex: 1, // Takes available space within scrollview
        justifyContent: 'center',
        padding: 25,
    },
    title: {
        fontSize: 28,
        fontWeight: 'bold',
        textAlign: 'center',
        marginBottom: 30,
        color: '#333',
    },
    inputGroup: {
        marginBottom: 20,
    },
    inputLabel: {
        fontSize: 14,
        color: '#555',
        marginBottom: 5,
    },
    input: {
        height: 50,
        borderColor: '#ccc',
        borderWidth: 1,
        marginBottom: 15,
        paddingHorizontal: 15,
        borderRadius: 8,
        backgroundColor: '#fff',
        fontSize: 16,
    },
    passwordContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        borderColor: '#ccc',
        borderWidth: 1,
        borderRadius: 8,
        backgroundColor: '#fff',
        marginBottom: 10, // Reduced margin before Forgot Password
    },
    inputPassword: {
        flex: 1,
        height: 50,
        paddingHorizontal: 15,
        fontSize: 16,
        borderRightWidth: 0, // Remove internal border
    },
    eyeButton: {
        padding: 15,
    },
    forgotPassword: {
         color: '#007bff',
         textAlign: 'right',
         marginBottom: 15,
         fontSize: 14,
    },
    separatorContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        marginVertical: 20,
    },
    separatorLine: {
        flex: 1,
        height: 1,
        backgroundColor: '#ccc',
    },
    separatorText: {
        marginHorizontal: 10,
        color: '#888',
        fontSize: 14,
    },
    buttonGroup: {
        // flexDirection: 'row', // Keep vertical for now, adjust if needed
        // justifyContent: 'space-between',
        marginBottom: 15,
    },
    buttonSpacer: {
        height: 10, // Space between vertical buttons
    },
    footer: {
        flexDirection: 'row',
        justifyContent: 'center',
        marginTop: 25,
        alignItems: 'center',
    },
    linkText: {
        color: '#007bff',
        fontWeight: 'bold',
    },
    errorText: {
        color: 'red',
        textAlign: 'center',
        marginBottom: 15,
        fontSize: 14,
    },
    loader: {
        marginVertical: 20,
    },
});

export default LoginScreen;