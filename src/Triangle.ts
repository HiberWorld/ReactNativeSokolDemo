import {NativeModules} from 'react-native';

type Triangle = {
  startTriangle: () => void;
};

export const Triangle: Triangle = NativeModules.TriangleModule;
