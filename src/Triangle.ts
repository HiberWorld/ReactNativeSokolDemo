import {NativeModules} from 'react-native';

export type TriangleCallbackResponse = {score: number};

export type TriangleCallback = (res: string) => any;
export interface Triangle {
  startTriangle: (callback: TriangleCallback) => void;
}

export default NativeModules.TriangleModule as Triangle;
