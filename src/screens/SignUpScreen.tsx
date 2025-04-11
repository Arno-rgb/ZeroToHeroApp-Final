import React from 'react';
import { View, Text, StyleSheet, Button } from 'react-native';

const SignUpScreen = ({ navigation }: { navigation: any }) => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Sign Up</Text>
      {/* TODO: Add Sign Up form fields (Email, Password, Username?) */}
      <Text style={{ marginVertical: 20 }}>(Sign Up Form Goes Here)</Text>
      <Button title="Go back to Login" onPress={() => navigation.goBack()} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20 },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 20 },
});

export default SignUpScreen;
