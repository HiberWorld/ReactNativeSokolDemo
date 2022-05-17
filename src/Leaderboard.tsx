import React from 'react';
import styled from 'styled-components/native';
import {colors} from './colors';

const LeaderboardContainer = styled.ScrollView`
  /* margin: 16px; */
  border-radius: 8px;
`;

const LeaderboardHeader = styled.Text`
  font-size: 32px;
  font-weight: 500;
  color: ${colors.white};
  margin: 16px;
`;

const LeaderboardEntry = styled.View<{selected?: boolean}>`
  color: ${colors.white};
  background-color: ${({selected}) =>
    selected ? colors.lighterDark : colors.almostBlack};
  border-radius: 8px;
  flex-direction: row;
  padding: 16px;
  justify-content: space-between;
`;

const LeaderboardEntryText = styled.Text`
  color: ${colors.white};
`;

const LeaderboardUserContainer = styled.View`
  flex-direction: row;
`;

const UserHead = styled.View`
  height: 6px;
  width: 6px;
  border-radius: 2px;
  background-color: ${colors.red};
`;

const UserBody = styled.View`
  margin-top: 1px;
  height: 5px;
  width: 12px;
  border-radius: 8px;
  background-color: ${colors.red};
`;

const UserCircle = styled.View`
  background-color: ${colors.white};
  border-radius: 8px;
  height: 16px;
  width: 16px;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  margin-right: 4px;
`;

const UserIcon = () => (
  <UserCircle>
    <UserHead />
    <UserBody />
  </UserCircle>
);

export type LeaderboardEntry = {
  username: string;
  score: number;
};

interface LeaderboardProps {
  leaderboardData: LeaderboardEntry[];
}

export default ({leaderboardData = []}: LeaderboardProps) => (
  <>
    <LeaderboardHeader>Leaderboard</LeaderboardHeader>
    <LeaderboardContainer>
      {leaderboardData
        .sort((a, b) => (a.score < b.score ? 1 : -1))
        .map(entry => (
          <LeaderboardEntry>
            <LeaderboardEntryText>{entry.score}</LeaderboardEntryText>
            <LeaderboardUserContainer>
              <UserIcon />
              <LeaderboardEntryText>{entry.username}</LeaderboardEntryText>
            </LeaderboardUserContainer>
          </LeaderboardEntry>
        ))}
    </LeaderboardContainer>
  </>
);
