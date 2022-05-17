import React, {useState} from 'react';
import {Pressable} from 'react-native';
import styled from 'styled-components/native';
import {colors} from './colors';

const PopupContainer = styled.View`
  background-color: ${colors.lighterDark};
  width: 100%;
  height: 100%;
  z-index: 10;
  border-radius: 8px;
  padding: 16px;
`;

const PopupText = styled.Text`
  color: ${colors.white};
  font-size: 32px;
  text-align: center;
`;

const PopupTitle = styled.Text`
  color: ${colors.white};
  font-size: 64px;
  text-align: center;
  font-weight: 500;
  line-height: 64px;
`;

const PopupInput = styled.TextInput`
  color: ${colors.almostBlack};
  background-color: ${colors.white};
  margin: 8px;
  padding: 8px;
  border-radius: 4px;
`;

const PopupSubmit = styled.Pressable`
  background-color: ${colors.red};
  border-radius: 8px;
  padding: 8px;
  margin: 20px;
`;

interface PopupProps {
  score: number;
  onSubmit: (username: string) => any;
}

export const Popup = ({score, onSubmit}: PopupProps) => {
  const [username, setUsername] = useState('');
  return (
    <PopupContainer>
      <PopupTitle>Your Triangle is No More!</PopupTitle>
      <PopupText>Score: {score} </PopupText>
      <PopupInput value={username} onChangeText={text => setUsername(text)} />
      <PopupSubmit onPress={() => onSubmit(username)}>
        <PopupText>Submit</PopupText>
      </PopupSubmit>
    </PopupContainer>
  );
};
