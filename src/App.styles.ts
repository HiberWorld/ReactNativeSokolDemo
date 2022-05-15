import styled from 'styled-components/native';
import {colors} from './colors';

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
