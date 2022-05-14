import styled from 'styled-components/native';

export const colors = {
  dark: '#1B1C20',
  veryDark: '#343540',
  almostBlack: '#292A31',
  red: '#E81623',
  white: '#FFFFFF',
};

export const DarkSafeArea = styled.SafeAreaView`
  background-color: ${colors.dark};
`;

export const FullPage = styled.View`
  background-color: ${colors.dark};
  height: 100%;
  padding-top: 20px;
  padding: 16px;
`;

export const PageTitle = styled.Text`
  font-size: 40px;
  font-weight: 600;
  color: ${colors.white};
  margin-left: 8px;
`;

export const TriangleContainer = styled.View`
  margin-top: 20px;
`;

export const TriangleButton = styled.Pressable`
  width: 100%;
  padding: 16px;
  border-radius: 8px;
  background-color: ${colors.red};
`;
export const TriangleButtonText = styled.Text`
  font-weight: 500;
  color: ${colors.white};
  text-align: center;
`;

export const LeaderboardContainer = styled.ScrollView`
  /* margin: 16px; */
  border-radius: 8px;
`;

export const LeaderboardHeader = styled.Text`
  font-size: 32px;
  font-weight: 500;
  color: ${colors.white};
  margin: 16px;
`;

export const LeaderboardEntry = styled.View`
  color: ${colors.white};
  background-color: ${colors.almostBlack};
  border-radius: 8px;
`;

export const LeaderboardEntryText = styled.Text`
  color: ${colors.white};
  margin: 16px;
`;
