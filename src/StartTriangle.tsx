import React from 'react';
import Triangle, {TriangleCallback} from './Triangle';
import styled from 'styled-components/native';
import {colors} from './colors';

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

interface StartTriangleProps {
  gameEndCallback: TriangleCallback;
}

export const StartTriangle = ({gameEndCallback}: StartTriangleProps) => {
  return (
    <TriangleContainer>
      <TriangleButton
        onPress={() => {
          console.log('starting');
          Triangle.startTriangle(gameEndCallback);
        }}>
        <TriangleButtonText>▲ Enter the Triangle ▲</TriangleButtonText>
      </TriangleButton>
    </TriangleContainer>
  );
};
