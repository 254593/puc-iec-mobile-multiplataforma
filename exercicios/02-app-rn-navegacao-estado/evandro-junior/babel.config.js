module.exports = function (api) {
  api.cache(true);
  return {
    // babel-preset-expo (SDK 54) já adiciona o plugin react-native-worklets/plugin
    // automaticamente quando o Reanimated 4 está instalado — não declarar de novo.
    presets: ['babel-preset-expo'],
    plugins: [
      // Path alias @/ → ./src/
      ['module-resolver', { root: ['./src'], alias: { '@': './src' } }],
    ],
  };
};
