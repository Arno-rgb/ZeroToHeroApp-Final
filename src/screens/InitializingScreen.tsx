import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated, Easing, SafeAreaView } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome'; // Or your preferred icon library

const InitializingScreen = () => {
  // Animated value for rotation
  const spinValue = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Configure the animation loop
    Animated.loop(
      Animated.timing(spinValue, {
        toValue: 1, // Rotate 360 degrees
        duration: 1500, // Speed of rotation
        easing: Easing.linear, // Constant speed
        useNativeDriver: true, // Use native driver for performance
      })
    ).start();
  }, [spinValue]);

  // Map the animated value (0 to 1) to a rotation degree (0deg to 360deg)
  const spin = spinValue.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <Animated.View style={{ transform: [{ rotate: spin }] }}>
          {/* You can replace this Icon with an Image */}
          <Icon name="refresh" size={60} color="#6366f1" />
        </Animated.View>
        <Text style={styles.text}>Initializing...</Text>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f3f4f6', // Match background if needed
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f3f4f6', // Light background
  },
  text: {
    marginTop: 20,
    fontSize: 18,
    color: '#4b5563', // Gray text
    fontWeight: '500',
  },
});

export default InitializingScreen;
