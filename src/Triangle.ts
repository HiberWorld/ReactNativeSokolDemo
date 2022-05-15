import {NativeModules} from 'react-native';

interface Triangle {
  startTriangle: (callback: (res: any) => void) => void;
}

export default NativeModules.TriangleModule as Triangle;
