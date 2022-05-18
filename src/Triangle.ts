import {
  EmitterSubscription,
  NativeEventEmitter,
  NativeModules,
} from 'react-native';

export type TriangleCallbackResponse = {score: number};

export type TriangleCallback = (res: string) => any;
export interface Triangle {
  startTriangle: (callback: TriangleCallback) => void;
}

const Triangle = NativeModules.TriangleModule;

export default Triangle;

const eventEmitter = Triangle && new NativeEventEmitter(Triangle);

type Event = {
  action: string;
  value: string;
};

type EventListener = (event: Event) => any;

export const addTriangleEventListener = (
  callback: EventListener,
): EmitterSubscription => eventEmitter.addListener('event', callback);
