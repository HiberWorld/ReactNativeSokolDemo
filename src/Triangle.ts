import {NativeModules} from 'react-native';

interface Triangle {
  startTriangle: () => void;
}

export default NativeModules.TriangleModule as Triangle;
