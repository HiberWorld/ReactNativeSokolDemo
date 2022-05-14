import React from 'react';
import {StatusBar} from 'react-native';
import {
  FullPage,
  PageTitle,
  TriangleContainer,
  TriangleButton,
  TriangleButtonText,
  LeaderboardContainer,
  LeaderboardHeader,
  LeaderboardEntry,
  LeaderboardEntryText,
  DarkSafeArea,
} from './App.styles';
import {Triangle} from './Triangle';

const TriangleStart = () => (
  <TriangleContainer>
    <TriangleButton
      onPress={() => {
        Triangle.startTriangle();
      }}>
      <TriangleButtonText>▲ Enter the Triangle ▲</TriangleButtonText>
    </TriangleButton>
  </TriangleContainer>
);

const Leaderboard = () => (
  <LeaderboardContainer>
    <LeaderboardHeader>Leaderboard</LeaderboardHeader>
    <LeaderboardEntry>
      <LeaderboardEntryText>100 points - Wilhelm</LeaderboardEntryText>
    </LeaderboardEntry>
  </LeaderboardContainer>
);

const App = () => {
  return (
    <DarkSafeArea>
      <StatusBar barStyle={'light-content'} />
      <FullPage>
        <PageTitle>Triangle Game</PageTitle>
        <TriangleStart />
        <Leaderboard />
      </FullPage>
    </DarkSafeArea>
  );
};

export default App;
