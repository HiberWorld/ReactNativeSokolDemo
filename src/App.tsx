import React from 'react';
import {StatusBar} from 'react-native';
import {
  FullPage,
  PageTitle,
  TriangleContainer,
  TriangleButton,
  TriangleButtonText,
  DarkSafeArea,
} from './App.styles';
import Leaderboard from './Leaderboard';
import Logo from './Logo';
import Triangle from './Triangle';

const TriangleStart = () => (
  <TriangleContainer>
    <TriangleButton
      onPress={() => {
        console.log('starting');
        Triangle.startTriangle(res => console.log('res: ', res));
      }}>
      <TriangleButtonText>▲ Enter the Triangle ▲</TriangleButtonText>
    </TriangleButton>
  </TriangleContainer>
);

const App = () => {
  return (
    <DarkSafeArea>
      <StatusBar barStyle={'light-content'} />
      <FullPage>
        <Logo />
        <PageTitle>Triangle Game</PageTitle>
        <TriangleStart />
        <Leaderboard />
      </FullPage>
    </DarkSafeArea>
  );
};

export default App;
