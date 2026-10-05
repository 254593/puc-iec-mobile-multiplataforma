// src/components/HeartButton.tsx
//
// ATIVIDADE 2 — TASK 8, opção A (heart pop).
//
// Escala 1 → 1.4 → 1 com mola + rotação leve. O callback de useAnimatedStyle é
// um worklet: roda na UI thread lendo os shared values a cada frame.
//
// Doc: https://docs.swmansion.com/react-native-reanimated/

import { Pressable, StyleSheet } from 'react-native';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSequence,
  withSpring,
  withTiming,
} from 'react-native-reanimated';

type Props = { active: boolean; onPress: () => void };

export default function HeartButton({ active, onPress }: Props) {
  const scale = useSharedValue(1);
  const rotation = useSharedValue(0);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }, { rotate: `${rotation.value}deg` }],
  }));

  const handlePress = () => {
    scale.value = withSequence(withTiming(1.4, { duration: 120 }), withSpring(1, { damping: 4 }));
    rotation.value = withSequence(withTiming(12, { duration: 120 }), withSpring(0, { damping: 5 }));
    onPress();
  };

  return (
    <Pressable
      onPress={(e) => {
        e.stopPropagation();
        handlePress();
      }}
      style={styles.heart}
    >
      <Animated.Text style={[styles.heartIcon, animatedStyle]}>{active ? '❤️' : '🤍'}</Animated.Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  heart: { padding: 8 },
  heartIcon: { fontSize: 24 },
});
